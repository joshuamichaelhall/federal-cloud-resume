# AWS Cloud Resume Challenge

A production-ready cloud resume website built on AWS, demonstrating cloud engineering and DevOps skills essential for federal cloud security engineering roles.

## Architecture

This project implements a serverless, scalable, and secure resume website using AWS services:

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
       ├──────────────────────────────────────┐
       │                                      │
       ▼                                      ▼
┌─────────────┐                      ┌──────────────┐
│ CloudFront  │                      │ API Gateway  │
│  (HTTPS)    │                      │              │
└──────┬──────┘                      └──────┬───────┘
       │                                    │
       ▼                                    ▼
┌─────────────┐                      ┌──────────────┐
│  S3 Bucket  │                      │   Lambda     │
│  (Static    │                      │  (Python)    │
│   Files)    │                      └──────┬───────┘
└─────────────┘                             │
                                            ▼
                                     ┌──────────────┐
                                     │  DynamoDB    │
                                     │  (Visitor    │
                                     │   Counter)   │
                                     └──────────────┘
```

### Components

- **Frontend**: Static HTML/CSS/JavaScript resume with visitor counter
- **CloudFront**: CDN for fast, secure HTTPS content delivery
- **S3**: Static website hosting with encryption and versioning
- **API Gateway**: HTTP API endpoint for visitor counter
- **Lambda**: Python function to increment/retrieve visitor count
- **DynamoDB**: NoSQL database for storing visitor count
- **Terraform**: Infrastructure as Code for reproducible deployments
- **GitHub Actions**: CI/CD pipeline for automated deployments

## Key Features

### Security
- ✅ HTTPS enforcement via CloudFront
- ✅ S3 bucket encryption (AES256)
- ✅ DynamoDB encryption at rest
- ✅ Least-privilege IAM roles
- ✅ S3 bucket public access blocking
- ✅ CloudFront Origin Access Control (OAC)
- ✅ X-Ray tracing for Lambda

### Operational Excellence
- ✅ Infrastructure as Code (Terraform)
- ✅ CI/CD with GitHub Actions
- ✅ CloudWatch logging and monitoring
- ✅ Automated CloudFront cache invalidation
- ✅ S3 versioning for rollback capability

### Cost Optimization
- ✅ Serverless architecture (pay per use)
- ✅ DynamoDB on-demand pricing
- ✅ CloudFront caching to reduce origin requests
- ✅ Lambda memory optimization (128MB)

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Git

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd test-cloud-resume
```

### 2. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to customize settings (optional - defaults work fine):

```hcl
aws_region = "us-east-1"
project_name = "cloud-resume"
s3_bucket_name = "" # Leave empty for auto-generated name
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply
```

After deployment, Terraform will output important values including your API Gateway URL and CloudFront distribution URL.

### 4. Update Frontend with API URL

```bash
# Get the API URL
API_URL=$(terraform output -raw api_gateway_url)

# Update the frontend JavaScript
cd ../frontend
sed -i "s|const API_URL = '.*';|const API_URL = '$API_URL';|g" script.js
```

### 5. Upload Frontend Files to S3

```bash
# Get the S3 bucket name
BUCKET_NAME=$(cd ../terraform && terraform output -raw s3_bucket_name)

# Sync files
aws s3 sync . s3://$BUCKET_NAME/ --exclude ".DS_Store"
```

### 6. Invalidate CloudFront Cache

```bash
# Get CloudFront distribution ID
DISTRIBUTION_ID=$(cd ../terraform && terraform output -raw cloudfront_distribution_id)

# Create invalidation
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

### 7. Access Your Website

```bash
# Get your website URL
cd ../terraform
terraform output website_url
```

Visit the URL displayed. The visitor counter should increment with each page visit!

## CI/CD with GitHub Actions

The project includes a complete CI/CD pipeline that automatically deploys changes when you push to the `main` branch.

### Setup GitHub Actions

1. **Configure AWS OIDC Provider** (recommended for security):

   ```bash
   # Create OIDC provider in AWS IAM
   # Follow: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
   ```

2. **Add GitHub Secrets**:
   - Go to repository Settings → Secrets and variables → Actions
   - Add secret: `AWS_ROLE_ARN` (the IAM role ARN for GitHub Actions)

3. **Push to trigger deployment**:

   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

The pipeline will:
- ✅ Run `terraform plan` on pull requests
- ✅ Apply infrastructure changes on merge to main
- ✅ Update the API URL in frontend files
- ✅ Sync frontend to S3
- ✅ Invalidate CloudFront cache
- ✅ Provide deployment summary

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── backend/
│   ├── lambda_function.py      # Lambda function code
│   └── requirements.txt        # Python dependencies
├── frontend/
│   ├── index.html              # Resume HTML
│   ├── styles.css              # Styling
│   └── script.js               # Visitor counter logic
├── terraform/
│   ├── main.tf                 # Main infrastructure config
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── terraform.tfvars.example # Example variable values
└── README.md                   # This file
```

## Customization

### Update Resume Content

Edit `frontend/index.html` to add your own:
- Personal information
- Work experience
- Certifications
- Skills
- Education

### Modify Styling

Edit `frontend/styles.css` to customize:
- Colors
- Fonts
- Layout
- Responsive breakpoints

### Add Custom Domain (Optional)

1. Register domain in Route53 or external registrar
2. Request ACM certificate in `us-east-1`
3. Update `terraform/main.tf` CloudFront distribution:

```hcl
resource "aws_cloudfront_distribution" "website" {
  # ... existing config ...

  aliases = ["resume.yourdomain.com"]

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT_ID"
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
```

4. Create Route53 alias record pointing to CloudFront

## Monitoring and Logs

### CloudWatch Logs

- **Lambda logs**: `/aws/lambda/cloud-resume-visitor-counter`
- **API Gateway logs**: `/aws/apigateway/cloud-resume-api`

### View Lambda Metrics

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=cloud-resume-visitor-counter \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

### Check Visitor Count

```bash
aws dynamodb get-item \
  --table-name cloud-resume-visitors \
  --key '{"id": {"S": "visitor_count"}}'
```

## Cost Estimate

Based on typical resume website traffic (1,000 visitors/month):

| Service | Estimated Monthly Cost |
|---------|----------------------|
| S3 Storage & Requests | $0.03 |
| CloudFront | $0.10 |
| Lambda | $0.00 (Free Tier) |
| DynamoDB | $0.00 (Free Tier) |
| API Gateway | $0.00 (Free Tier) |
| **Total** | **~$0.13/month** |

## Troubleshooting

### Issue: Visitor counter shows "Unavailable"

**Solution**: Check that:
1. API Gateway URL is correctly set in `frontend/script.js`
2. CORS is properly configured
3. Lambda has DynamoDB permissions

```bash
# Test API directly
curl -X POST https://YOUR_API_URL/visitor
```

### Issue: CloudFront shows old content

**Solution**: Invalidate the cache:

```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

### Issue: Terraform apply fails

**Solution**: Check AWS credentials and permissions:

```bash
aws sts get-caller-identity
```

Ensure your IAM user/role has permissions for:
- S3, CloudFront, Lambda, DynamoDB, API Gateway, IAM, CloudWatch

## Clean Up

To avoid ongoing charges, destroy all resources:

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted. This will remove all AWS resources created by this project.

## Skills Demonstrated

This project showcases skills relevant to federal cloud security engineering:

- ✅ **AWS Services**: S3, CloudFront, Lambda, DynamoDB, API Gateway, IAM, CloudWatch
- ✅ **Infrastructure as Code**: Terraform
- ✅ **Security Best Practices**: Encryption, least privilege, HTTPS
- ✅ **DevOps/CI/CD**: GitHub Actions automation
- ✅ **Serverless Architecture**: Event-driven, scalable design
- ✅ **Programming**: Python, JavaScript
- ✅ **Compliance**: Documentation, monitoring, logging

## Next Steps for Federal Roles

To enhance this project for federal cloud security positions:

1. **Implement FedRAMP controls**:
   - Enable AWS Config for compliance monitoring
   - Add AWS Security Hub integration
   - Implement CloudTrail for audit logging

2. **Add WAF protection**:
   - Deploy AWS WAF on CloudFront
   - Implement rate limiting
   - Add IP reputation lists

3. **Enhance monitoring**:
   - Set up CloudWatch alarms
   - Create SNS notifications
   - Implement AWS X-Ray for distributed tracing

4. **Add automated testing**:
   - Unit tests for Lambda
   - Integration tests for API
   - Security scanning (Bandit, Safety)

## License

MIT License - Feel free to use this project as a template for your own cloud resume.

## Acknowledgments

Based on the Cloud Resume Challenge by Forrest Brazeal.

## Contact

For questions or feedback about this project, please open an issue in the repository.
