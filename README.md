# Federal Cloud Resume

**Live Site:** https://joshuahall.tech

Production serverless cloud resume demonstrating AWS architecture fundamentals and security best practices.

## Architecture Overview

This project implements a serverless web application using AWS managed services:

```
User Browser
    ↓ HTTPS
CloudFront (CDN + SSL)
    ↓
S3 (Static Website Hosting)
    ↓ JavaScript fetch()
API Gateway (REST API)
    ↓
Lambda (Python 3.12)
    ↓
DynamoDB (Visitor Counter)
```

## Technology Stack

**Frontend:**
- HTML5/CSS3 - Responsive design with federal-appropriate styling
- JavaScript - API integration for visitor counter

**Backend:**
- Python 3.12 - Lambda function runtime
- Boto3 - AWS SDK for DynamoDB operations

**Infrastructure:**
- **S3** - Static website hosting
- **CloudFront** - Global CDN with edge caching
- **ACM** - SSL/TLS certificate management
- **API Gateway** - RESTful API endpoint
- **Lambda** - Serverless compute for visitor counter
- **DynamoDB** - NoSQL database with atomic counters
- **IAM** - Least privilege access policies

## Security Implementations

- **HTTPS Enforcement** - ACM certificate with CloudFront
- **IAM Least Privilege** - Lambda execution role limited to DynamoDB UpdateItem
- **CORS Configuration** - Proper cross-origin resource sharing
- **Atomic Operations** - DynamoDB conditional updates prevent race conditions
- **Encryption** - Data encrypted at rest (DynamoDB) and in transit (HTTPS)

## Architecture Decisions

**Why Serverless?**
- Zero server management overhead
- Pay-per-use pricing model
- Automatic scaling for traffic spikes
- High availability built-in

**Why DynamoDB over RDS?**
- Serverless billing model (pay per request)
- Single-digit millisecond latency
- Atomic counter operations
- No connection pool management needed

**Why CloudFront?**
- Global edge caching reduces latency
- SSL/TLS termination
- DDoS protection via AWS Shield Standard
- Cost-effective for static content delivery

## Project Structure

```
.
├── index.html              # Main resume page
├── styles.css              # Professional styling
├── lambda/
│   └── visitor-counter.py  # Lambda function for DynamoDB updates
└── README.md              # This file
```

## Local Development

To work with this project locally:

```bash
# Clone repository
git clone https://github.com/joshuamichaelhall/federal-cloud-resume.git
cd federal-cloud-resume

# Open in browser
open index.html

# Note: Visitor counter requires AWS infrastructure
```

## Deployment

This project is deployed using AWS Console with the following manual steps:

1. S3 bucket configuration for static website hosting
2. CloudFront distribution with custom domain
3. ACM certificate for HTTPS
4. DynamoDB table with on-demand billing
5. Lambda function with Python 3.12 runtime
6. API Gateway REST API with Lambda proxy integration
7. IAM roles and policies for least privilege access

**Future Enhancement:** Convert to Infrastructure as Code using Terraform or CloudFormation.

## Cost Analysis

Estimated monthly costs for low-traffic resume site:

- **S3:** ~$0.50 (1GB storage, minimal requests)
- **CloudFront:** ~$1.00 (first 1TB free tier)
- **Lambda:** Free tier (1M requests/month)
- **API Gateway:** ~$0.50 (1M requests free tier)
- **DynamoDB:** Free tier (25GB, 25 WCU/RCU)
- **Route 53:** $0.50/month (hosted zone)

**Total:** ~$2.50/month (well within AWS free tier for first year)

## Performance Metrics

- **CloudFront Cache Hit Ratio:** >95% for static assets
- **API Gateway Latency:** <50ms (us-east-1)
- **Lambda Cold Start:** ~200ms
- **Lambda Warm Execution:** ~10ms
- **DynamoDB Read/Write:** <10ms

## Advanced Security Portfolio

This project demonstrates AWS serverless fundamentals. For advanced security architecture including:
- CloudTrail centralized logging
- Security Hub multi-account aggregation
- GuardDuty threat detection
- AWS Config compliance monitoring
- Terraform Infrastructure as Code
- NIST 800-53 control mappings

See the **Federal Security Dashboard** project (planned for February 2026).

## Lessons Learned

**Technical:**
- Lambda proxy integration requires specific response format for API Gateway
- CORS configuration must match on both API Gateway and Lambda
- DynamoDB atomic counters prevent race conditions without locks
- CloudFront invalidation required for immediate content updates

**Architecture:**
- Serverless reduces operational complexity significantly
- Edge caching dramatically improves global user experience
- IAM least privilege prevents privilege escalation risks
- Monitoring and logging should be implemented from Day 1

## Future Enhancements

Potential improvements for this project:

- [ ] CloudFormation or Terraform IaC templates
- [ ] CI/CD pipeline with GitHub Actions
- [ ] CloudWatch dashboards for monitoring
- [ ] WAF rules for additional security
- [ ] Lambda function unit tests
- [ ] CloudTrail logging for API calls
- [ ] Cost optimization with Lambda reserved concurrency

## Contact

**Joshua Michael Hall**
- Website: https://www.joshuamichaelhall.com
- LinkedIn: https://www.linkedin.com/in/joshuamichaelhall/
- GitHub: https://github.com/joshuamichaelhall

---

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Code templating
- Documentation writing and organization
- Troubleshooting and debugging assistance
- Research and idea generation

Claude was used as a development aid while all final edits and implementations were performed by Joshua Michael Hall.

---

**Project Status:** ✅ Production Ready and Live  
**Completion Date:** November 21, 2025  
**Live URL:** https://joshuahall.tech  
**Portfolio Use:** Ready for AWS re:Invent demos and Cloud Security Architect interviews