# Project Presentation

*Selecting the 1st project from Manara SAA Graduation Project Ideas* [[app.manara.tech]]*, as shown below*

> Architecture: EC2-Based 
>
   Description: Deploy a production-grade web application on AWS using EC2 instances inside a properly architected VPC with public and private subnets across two Availability Zones. Achieve high availability and scalability with ALB, ASG, and a CloudFront distribution for caching static assets. A Multi-AZ RDS instance serves as the database backend, with all compute in private subnets.
>
   Key AWS Services:
>
>- VPC: Public & private subnets, NAT Gateway, Security Groups, NACLs
>- EC2 + ASG: Launch Template, scaling policies (target tracking)
>- ALB + WAF: Layer 7 routing, WAF rules for OWASP Top 10   
>- CloudFront: Cache static assets, reduce latency
>- RDS Multi-AZ: MySQL/PostgreSQL with automated failover
>- Route 53: Public alias record pointing to CloudFront (CloudFront uses the ALB as its origin)
>- Systems Manager: Session Manager for secure instance access
>- CloudWatch + SNS: Dashboards, alarms, and notifications
>
Learning Outcomes:
>
>- Design VPCs with correct subnet, route table, and NAT Gateway configurations   
>- Build highly available architectures across multiple Availability Zones
>- Configure ALB listener rules and target group health checks
>- Implement Auto Scaling with target tracking and step scaling policies
>- Secure applications with WAF, Security Groups, and private subnets
>- Use Systems Manager Session Manager as a bastion-free access alternative

# Solutions Design and Architecture

## I. Service and Components Choice

``` PlainText
VPC (Regional)
│
├── Internet Gateway (IGW)
│
├── AZ-a
│   ├── Public Subnet
│   │   ├── ALB Node
│   │   └── NAT Gateway
│   │
│   ├── Private Application Subnet
│   │   ├── EC2 Instance #1
│   │   └── Interface Endpoint (ENI)
│   │
│   └── Private Database Subnet
│       └── RDS Primary (Writer)
│
└── AZ-b
    ├── Public Subnet
    │   ├── ALB Node
    │   └── NAT Gateway
    │
    ├── Private Application Subnet
    │   ├── EC2 Instance #2
    │   └── Interface Endpoint (ENI)
    │
    └── Private Database Subnet
        └── RDS Standby (Reader also in new architectures)
```

## 2. Architecture Decisions

**1. Regional VPC**

A single regional VPC hosts all application components and networking constructs, providing centralized network segmentation, security controls, and connectivity across multiple Availability Zones.

---

**2. Auto Scaling Group (ASG)**

A regional Auto Scaling Group spans multiple Availability Zones to provide:

- High Availability (HA)
- Self-healing capabilities
- Future horizontal scalability

A minimum capacity of **two EC2 instances** is maintained, with one instance deployed in each Availability Zone to eliminate single points of failure.

---

**3. Amazon RDS Multi-AZ Deployment**

Amazon RDS is deployed in a Multi-AZ configuration across two Availability Zones.

- One database instance acts as the **primary writer**.
- A secondary instance provides **high-availability failover protection**.
- In the modern Multi-AZ DB Cluster architecture, additional instances can also serve **read traffic**, enabling read scaling while preserving automatic failover capabilities.

---

**4. Network and Tier Segmentation**

Dedicated private subnets are used for each application tier:

- Application Tier Subnets
- Database Tier Subnets

This separation improves security, simplifies access control implementation, and supports future workload growth without requiring network redesign.

---

**5. Application Load Balancer (ALB)**

The Application Load Balancer is a **regional service** deployed across multiple Availability Zones.

AWS automatically provisions ALB nodes in the selected public subnets, ensuring:

- High Availability
- Cross-AZ load distribution
- Integration with the Auto Scaling Group

The ALB distributes incoming HTTP(S) traffic to healthy EC2 targets registered within its Target Group.

---

**6. Amazon CloudFront**

Amazon CloudFront is deployed as the Internet-facing entry point to the application.

Key responsibilities include:

- Global content delivery through AWS Edge Locations
- Caching of static and cacheable content
- Reduced latency for end users
- Reduced load on backend infrastructure

CloudFront uses the ALB as its origin and forwards cache-miss requests to the application layer.

**Traffic flow:**

``` Plain Text
User
  ↓
Route 53
  ↓
CloudFront
  ↓
ALB
  ↓
EC2 Instances
```
---

**7. AWS WAF**

AWS WAF is associated with the CloudFront distribution.

This ensures that malicious requests are inspected and filtered **before reaching the origin infrastructure**, providing:

- OWASP Top 10 protections
- IP reputation filtering
- Geo-blocking capabilities
- Custom application security rules

**Note:** The WAF is not physically placed "before CloudFront". Rather, it is attached to CloudFront and evaluates requests at the CloudFront edge locations before they are forwarded to the ALB.

---

**8. Internet Egress Architecture**

To provide resilient outbound Internet connectivity:

- One NAT Gateway is deployed per Availability Zone.
- NAT Gateways reside in public subnets.
- Private application subnets route Internet-bound outbound traffic through their local NAT Gateway.
- A regional Internet Gateway (IGW) provides Internet connectivity for public resources and NAT Gateway egress traffic.

This design avoids cross-AZ dependency and minimizes failure impact during an Availability Zone outage.

---

**9. AWS Systems Manager Session Manager**

AWS Systems Manager Session Manager is used for secure administrative access to EC2 instances without requiring:

- Bastion Hosts
- Public IP addresses
- Inbound SSH access

Each EC2 instance runs the **SSM Agent**, which initiates outbound connections to AWS Systems Manager through Interface VPC Endpoints.

Benefits include:

- Fully private administration over the AWS backbone
- Auditable access sessions
- Reduced attack surface
- Elimination of SSH key management

### III. High-level Request Flow

``` PlainText
User
  ↓
Route 53
  ↓
CloudFront + AWS WAF
  ↓
Application Load Balancer
  ↓
Auto Scaling Group (EC2)
  ↓
Amazon RDS Multi-AZ
```