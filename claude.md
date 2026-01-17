# CLAUDE.md - Federal Cloud Resume

## Context
Production serverless cloud resume demonstrating AWS architecture fundamentals and security best practices. This is a live site at https://joshuahall.tech showcasing AWS skills for federal defense contractor positions.

## Architecture
```
User Browser → CloudFront (CDN + SSL) → S3 (Static Hosting)
                                     → API Gateway → Lambda (Python 3.12) → DynamoDB
```

## Repository Structure
```
federal-cloud-resume/
├── frontend/          # Static website files (HTML, CSS, JS)
├── backend/           # Lambda function code (Python)
├── infrastructure/    # IaC templates (future: Terraform/CloudFormation)
├── dist-config.json   # Distribution configuration
└── updated-config.json
```

## Live Site
- **URL:** https://joshuahall.tech
- **Status:** Production Ready
- **Hosting:** AWS (S3, CloudFront, Lambda, DynamoDB, API Gateway)

## Development Guidelines

### Frontend Changes
1. Edit files in `frontend/`
2. Test locally: `open frontend/index.html`
3. Note: Visitor counter requires AWS infrastructure

### Backend Changes
1. Lambda code is in `backend/`
2. Runtime: Python 3.12
3. Uses boto3 for DynamoDB operations
4. Test locally with AWS SAM or deploy to test environment

### Deployment
Currently manual via AWS Console. Steps:
1. Upload frontend to S3 bucket
2. Invalidate CloudFront cache: `aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"`
3. Update Lambda function if backend changed

## Security Considerations
- HTTPS enforced via ACM + CloudFront
- IAM least privilege on Lambda execution role
- CORS configured for joshuahall.tech domain
- DynamoDB encryption at rest enabled

## AWS Services Used
- S3 (static hosting)
- CloudFront (CDN, SSL termination)
- ACM (certificate management)
- API Gateway (REST API)
- Lambda (serverless compute)
- DynamoDB (visitor counter storage)
- IAM (access policies)

## Future Enhancements
- [ ] Infrastructure as Code (Terraform)
- [ ] CI/CD with GitHub Actions
- [ ] CloudWatch monitoring dashboards
- [ ] Lambda unit tests

## Related Documentation
- `NIST_800-53_CONTROL_FOUNDATIONS.md` - Security control mappings
- `Content Creation Strategy.md` - Content planning
