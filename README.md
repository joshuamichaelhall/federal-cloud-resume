# Federal Cloud Resume

Professional resume demonstrating AWS serverless architecture with federal security compliance.

**Live Demo:** [https://joshuahall.tech](https://joshuahall.tech)

[![AWS](https://img.shields.io/badge/AWS-Serverless-orange)](https://aws.amazon.com)
[![Python](https://img.shields.io/badge/Python-3.11-blue)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Overview

This project showcases a secure, scalable serverless resume architecture aligned with federal compliance requirements. Built as a demonstration of cloud security engineering capabilities for Solutions Engineering roles in the defense sector.

### Key Features

- **Serverless Architecture**: No servers to manage, automatic scaling
- **HTTPS with Custom Domain**: Professional presentation with ACM certificate
- **Real-time Visitor Counter**: Demonstrates API integration and state management
- **Federal Compliance**: NIST 800-53 control mappings documented
- **Cost-Optimized**: Runs at ~$2-5/month with unlimited traffic capacity
- **Mobile-Responsive**: Professional appearance across all devices

---

## Architecture

![Architecture Diagram](docs/architecture-diagram.png)

### Frontend
- **Static Hosting**: Amazon S3 with versioning
- **Content Delivery**: CloudFront with edge caching
- **SSL/TLS**: AWS Certificate Manager (ACM)
- **DNS**: Route 53 with alias records

### Backend
- **API Gateway**: REST API with CORS configuration
- **Compute**: AWS Lambda (Python 3.11)
- **Database**: DynamoDB (on-demand billing)
- **Secrets**: Systems Manager Parameter Store

### Security & Monitoring
- **Audit Logging**: AWS CloudTrail
- **Threat Detection**: Amazon GuardDuty
- **Access Control**: IAM roles with least privilege
- **Compliance**: NIST 800-53 control mappings

### Data Flow
1. User accesses joshuahall.tech via HTTPS
2. CloudFront serves cached static content from S3
3. JavaScript makes API call to increment visitor counter
4. API Gateway invokes Lambda function
5. Lambda atomically updates DynamoDB counter
6. Response returned to user with updated count
7. CloudTrail logs all API calls for audit

---

## Technology Stack

**Frontend:**
- HTML5, CSS3 (responsive design)
- Vanilla JavaScript (no frameworks)
- Mobile-first approach

**Backend:**
- Python 3.11
- Boto3 (AWS SDK)
- Lambda runtime environment

**Infrastructure:**
- AWS S3, CloudFront, Lambda, API Gateway, DynamoDB
- Route 53, ACM, CloudTrail, GuardDuty
- IAM for security and access control

**Development:**
- Git/GitHub for version control
- AWS CLI for deployments

---

## NIST 800-53 Compliance

This project implements security controls aligned with NIST 800-53 requirements:

- **AC-3 (Access Enforcement)**: IAM roles enforce least privilege
- **AC-6 (Least Privilege)**: Lambda has minimum necessary DynamoDB permissions
- **AU-2 (Audit Events)**: CloudTrail logs all API activity
- **AU-9 (Protection of Audit Information)**: CloudTrail logs in separate S3 bucket
- **SC-7 (Boundary Protection)**: CloudFront and API Gateway enforce HTTPS
- **SC-8 (Transmission Confidentiality)**: TLS 1.2+ encryption in transit
- **SC-13 (Cryptographic Protection)**: ACM manages TLS certificates
- **SI-4 (Information System Monitoring)**: GuardDuty monitors for threats

See [NIST-800-53-Mappings.md](docs/NIST-800-53-Mappings.md) for detailed control implementation.

---

## Cost Breakdown

Monthly operational costs (estimated):

| Service | Usage | Monthly Cost |
|---------|-------|--------------|
| S3 Storage | < 1 GB | $0.02 |
| CloudFront | First 1 TB free | $0.00-2.00 |
| Lambda | < 1M invocations | $0.00 (free tier) |
| DynamoDB | On-demand | $0.00-0.50 |
| API Gateway | < 1M calls | $0.00-3.50 |
| Route 53 | 1 hosted zone | $0.50 |
| ACM Certificate | — | $0.00 (free) |
| CloudTrail | Basic | $0.00 (free tier) |
| **Total** | | **~$2-5/month** |

**Scalability**: Architecture handles 10K+ visitors/month at same cost due to CloudFront caching and serverless pay-per-use model.

---

## Prerequisites

- AWS Account with billing alerts configured
- AWS CLI installed and configured
- Git for version control
- Python 3.9+ for local Lambda testing
- Text editor (VS Code, Neovim, etc.)
- Domain registered (or use CloudFront domain)

---

## Deployment Instructions

### Manual Deployment (2 days)

**Day 1: Infrastructure Setup**

1. **Clone repository:**
   ```bash
   git clone https://github.com/joshuamichaelhall/federal-cloud-resume.git
   cd federal-cloud-resume
   ```

2. **Deploy frontend to S3:**
   ```bash
   BUCKET_NAME="your-bucket-name"
   aws s3 mb s3://${BUCKET_NAME} --region us-east-1
   aws s3 sync frontend/ s3://${BUCKET_NAME}/
   ```

3. **Create CloudFront distribution:**
   - Use AWS Console for initial setup
   - Configure OAC for S3 origin
   - Enable HTTPS redirect

4. **Create DynamoDB table:**
   ```bash
   aws dynamodb create-table \
     --table-name visitor-counter \
     --attribute-definitions AttributeName=id,AttributeType=S \
     --key-schema AttributeName=id,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region us-east-1
   ```

5. **Deploy Lambda function:**
   ```bash
   cd backend
   zip lambda_function.zip lambda_function.py
   aws lambda create-function \
     --function-name visitor-counter \
     --runtime python3.11 \
     --role arn:aws:iam::ACCOUNT-ID:role/lambda-role \
     --handler lambda_function.lambda_handler \
     --zip-file fileb://lambda_function.zip \
     --environment Variables={TABLE_NAME=visitor-counter}
   ```

6. **Configure API Gateway:**
   - Create REST API in AWS Console
   - Create /count resource with GET method
   - Enable CORS
   - Deploy to prod stage

**Day 2: Custom Domain & Security**

7. **Migrate domain to Route 53:**
   ```bash
   aws route53 create-hosted-zone --name joshuahall.tech
   # Update nameservers at Namecheap
   ```

8. **Request ACM certificate:**
   ```bash
   aws acm request-certificate \
     --domain-name joshuahall.tech \
     --validation-method DNS
   ```

9. **Enable CloudTrail logging:**
   ```bash
   aws cloudtrail create-trail \
     --name federal-resume-trail \
     --s3-bucket-name cloudtrail-logs-bucket
   aws cloudtrail start-logging --name federal-resume-trail
   ```

10. **Test end-to-end:**
    ```bash
    curl https://joshuahall.tech
    ```

---

## Local Development

**Test Lambda function locally:**
```bash
cd backend
python3 -c "
import lambda_function
event = {'httpMethod': 'GET'}
result = lambda_function.lambda_handler(event, None)
print(result)
"
```

**Serve frontend locally:**
```bash
cd frontend
python3 -m http.server 8000
# Open http://localhost:8000
```

**Update Lambda code:**
```bash
cd backend
zip lambda_function.zip lambda_function.py
aws lambda update-function-code \
  --function-name visitor-counter \
  --zip-file fileb://lambda_function.zip
```

---

## Testing

**Frontend testing:**
- [ ] Page loads on Chrome, Firefox, Safari
- [ ] Mobile responsive (test on actual device)
- [ ] Visitor counter displays and increments
- [ ] No console errors

**Backend testing:**
```bash
# Test Lambda directly
aws lambda invoke \
  --function-name visitor-counter \
  --payload '{"httpMethod": "GET"}' \
  response.json

# Test API Gateway endpoint
curl https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/count
```

**Security testing:**
- [ ] CloudTrail logging enabled
- [ ] IAM policies use least privilege
- [ ] HTTPS enforced (no HTTP access)
- [ ] S3 bucket not publicly listable

---

## Monitoring

**CloudWatch Metrics:**
- Lambda invocations, errors, duration
- API Gateway request count, 4xx/5xx errors
- DynamoDB read/write capacity
- CloudFront cache hit ratio

**CloudTrail Logs:**
- All API calls logged with user identity
- Review logs for unauthorized access attempts

**Cost Monitoring:**
- Set billing alerts at $10 threshold
- Review AWS Cost Explorer monthly

---

## Troubleshooting

### Issue: CloudFront returns 403 Forbidden
**Solution:**
- Verify S3 bucket policy allows CloudFront OAC
- Check CloudFront origin configuration
- Ensure default root object is set to index.html

### Issue: CORS errors in browser console
**Solution:**
- Verify API Gateway CORS enabled on OPTIONS method
- Check Lambda returns correct CORS headers
- Redeploy API Gateway after CORS changes

### Issue: Visitor counter not incrementing
**Solution:**
- Check Lambda CloudWatch logs for errors
- Verify IAM role has DynamoDB UpdateItem permission
- Test DynamoDB table directly with AWS CLI

### Issue: Certificate validation pending
**Solution:**
- Check DNS validation CNAME record added correctly
- Wait 5-30 minutes for validation
- Verify Route 53 nameservers updated at registrar

---

## Security Best Practices

- **Never commit secrets**: Use environment variables and Parameter Store
- **Least privilege IAM**: Lambda has minimum necessary permissions
- **Enable MFA**: Require MFA for AWS account root and IAM users
- **Rotate credentials**: Regularly rotate AWS access keys
- **Monitor costs**: Set billing alarms to prevent unexpected charges
- **Regular updates**: Keep Lambda runtime and dependencies current
- **Backup data**: Enable DynamoDB point-in-time recovery (if needed)

---

## AI Assistance Disclosure

This project demonstrates ethical and strategic AI usage in cloud engineering:

**AI-Assisted (Claude):**
- Documentation structure and technical writing
- Code review and best practices validation
- NIST 800-53 control mapping documentation
- Troubleshooting and debugging assistance
- Content refinement and clarity improvements

**Human Implementation (Joshua Michael Hall):**
- All AWS service configuration and deployment
- Core Lambda function logic and error handling
- Architecture design decisions and tradeoffs
- Security implementation and IAM policies
- Integration testing and validation
- Performance optimization and cost analysis

AI was used as a development aid and force multiplier while all implementation decisions, architecture choices, and deployments were performed by the project owner. This approach demonstrates how modern cloud engineers leverage AI tools to accelerate delivery without compromising technical depth or architectural understanding.

---

## Contributing

This is a personal portfolio project. Issues and suggestions welcome via GitHub Issues.

**For similar implementations:**
1. Fork this repository
2. Customize frontend content
3. Update domain and AWS account details
4. Deploy using instructions above

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Author

**Joshua Michael Hall**  
Security Solutions Professional | AWS + CMMC

- Portfolio: [joshuamichaelhall.com](https://joshuamichaelhall.com)
- GitHub: [@joshuamichaelhall](https://github.com/joshuamichaelhall)
- LinkedIn: [linkedin.com/in/joshuamichaelhall](https://linkedin.com/in/joshuamichaelhall)
- Email: contact@joshuamichaelhall.com

---

## Acknowledgements

Built with assistance from Anthropic's Claude AI assistant for documentation, code review, and architecture refinement. All implementation decisions and AWS deployments performed by Joshua Michael Hall.

**Technologies:**
- AWS Serverless Services
- Python 3.11 and Boto3
- CloudFront CDN
- Route 53 DNS
- ACM Certificate Management

**Inspired by:**
- Cloud Resume Challenge
- AWS Well-Architected Framework
- NIST 800-53 Security Controls

---

**Last Updated:** November 2025
**Status:** Production Ready