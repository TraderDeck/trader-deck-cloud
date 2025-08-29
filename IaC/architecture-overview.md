# TraderDeck Cloud Architecture Overview

## High-Level Layers

### 1. Edge / Delivery
- **Route53 (implied)** → **CloudFront distribution** (aliases mytraderdeck.com, ACM cert TLS 1.2 2021)
- **CloudFront Origins/Behaviors:**
  - Origin A: S3 static site bucket (frontend) – default behavior (SPA rewrites 403/404 → index.html)
  - Origin B: ALB (internet-facing) – `/api/*` behavior (no caching, passes all headers, cookies, query strings)
  - Origin C: S3 td-ticker-icons bucket – `/logos/*` behavior (very long cache) via Origin Access Control (plus legacy OAI style policy)

### 2. VPC (10.16.0.0/16)
- Public subnets (1,2,3) in us-east-1a/1b (subnet_1 & 2 auto-assign public IPs; 3 lacks map_public_ip_on_launch)
- Private subnets (4–8) for app/data tiers (two /20 blocks plus two /24s for specialized workloads)
- Internet Gateway attached
- Single custom Network ACL applied to all subnets (rules not shown)
- Route Tables:
  - Public RT: `0.0.0.0/0` → IGW (assoc with subnets 1–3)
  - Private RT: `0.0.0.0/0` → ENI of a custom “fck_nat” EC2 instance (cheap NAT substitute) (assoc with subnets 4–8)

### 3. Compute / Application
- EC2 Backend (Spring Boot on 8080) in a public subnet (should ideally be private) without public IP, fronted by ALB
- Application Load Balancer in public subnets 1 & 2:
  - Listener 80 → redirect to 443
  - Listener 443 → target group (port 8080) health check `/actuator/health`
- Bastion host (separate ec2 module) in a public subnet for SSH access to private resources
- (Potential future move: backend + lambdas into private subnets 4–6)

### 4. Data
- RDS PostgreSQL (db.t3.micro) private (publicly_accessible=false) in DB subnet group (subnets 5 & 4 across AZs)
- Secrets Manager holds DB credentials (looked up at provisioning)

### 5. Storage & Assets
- S3 frontend bucket (static site) – origin for UI
- S3 td-ticker-icons bucket – ticker/logo assets (CloudFront read, Lambdas write, EC2 role read as needed)
- S3 td-misc bucket – supporting CSV/data objects (Lambda write, EC2 read)

### 6. Serverless
- Lambda functions (store_ticker_icons, update_s3_metadata_file):
  - Write/read objects in td-ticker-icons and td-misc
  - (Security group lambda-rds-access-sg) permits direct PostgreSQL access via rds_sg ingress

### 7. Security Controls
- **Security Groups:**
  - ALB SG: Ingress 80/443 from 0.0.0.0/0; egress restricted (only tcp 8080) – may block external calls
  - Backend EC2 SG: Ingress 8080 from ALB SG; egress likely broad (file not shown)
  - Bastion SG: SSH ingress (not shown) → allows RDS ingress (rds_sg rule)
  - RDS SG: Ingress 5432 from backend SG, bastion SG, lambda SG; egress all
  - Lambda SG: Ingress none (initiates outbound) + referenced in RDS SG
- **IAM:**
  - EC2 instance profile TraderDeckEC2Role (S3 object read, maybe Secrets/CloudWatch)
  - Lambda roles with scoped S3 and (implied) Secrets / RDS access
  - Bucket policies enforcing least privilege and CloudFront origin access (mix of OAI/OAC)

### 8. Configuration / Secrets
- AWS Secrets Manager for DB username/password (injected at Terraform apply time)

### 9. Traffic Flows
- **A. End User → CloudFront (HTTPS):**
  - Static assets / index → S3 frontend bucket
  - Logos /images → S3 td-ticker-icons
  - API calls `/api/*` → CloudFront → ALB → EC2 backend → RDS / S3 / Secrets (startup)
- **B. Lambdas (trigger mechanism not shown; likely manual or event) → S3 (write logos/metadata) → optionally RDS (tickers)**
- **C. Backend EC2 → RDS (5432) & S3 (read misc/logo data) & possibly outbound internet via IGW (public subnet) or via NAT if moved private**
- **D. Private subnets outbound → NAT instance (fck_nat) → IGW → Internet**
- **E. Admin SSH → Bastion (public) → Private resources (EC2/Lambdas via VPC networking / RDS)**

### 10. Diagram Sketch Guidance (suggested grouping)
- Left: Users (Browser)
- Top Edge: Route53 (optional) → CloudFront (box with 3 behaviors)
- Beneath CloudFront: three origin boxes:
  - S3 Frontend (static) (bucket icon)
  - S3 Logos (bucket icon)
  - ALB (load balancer icon) → EC2 Backend (instance icon)
- VPC big boundary with subnets:
  - Public AZ1: Subnet 1 (ALB, NAT instance, Bastion)
  - Public AZ2: Subnet 2 (ALB)
  - Private AZ1: Subnet 5 (RDS subnet group member) + Subnet 4 in AZ2
  - Show other private subnets as future capacity
- RDS (DB icon) in private subnets (subnet group)
- Lambdas (two function icons) inside private (or shared) area connected to:
  - S3 buckets (icons)
  - RDS (dashed line if optional)
- NAT instance between private subnets and IGW (arrow outward)
- Security groups annotated on arrows:
  - CloudFront → ALB 443
  - ALB → Backend 8080
  - Backend/Lambdas/Bastion → RDS 5432
- Optional side: Secrets Manager (key icon) linked to Terraform provisioning + backend/Lambdas (for credentials retrieval)

### 11. Notable Gaps / Risks
- Single EC2 instance (no ASG) – SPOF
- Custom NAT instance (cost-optimized but operational risk; replace with managed NAT Gateway if scale)
- Backend in public subnet (move to private + add proper outbound path)
- Mixed OAI/OAC usage (standardize on OAC)
- ALB SG restrictive egress (may break external API calls)
- Very long cache for /logos without versioning

**Legend (optional):**
- Solid arrow: primary request path
- Dashed arrow: management / data sync
- Shield badge near SG labels; lock icon for private subnets; globe for public

Use this to draw in tools like draw.io, Lucidchart, or AWS Architecture Icons.
