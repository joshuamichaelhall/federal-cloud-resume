# AWS Final Cleanup Guide

After the CloudFront Security Bundle pricing plan transitions to pay-as-you-go (~June 1, 2026), run the following commands to delete the remaining three resources.

## Already Deleted

- [x] API Gateway (`visitor-counter-api`)
- [x] Lambda (`visitor-counter`)
- [x] DynamoDB (`visitor-counter`)
- [x] IAM Role (`visitor-counter-lambda-role`)
- [x] S3 Bucket (`federal-resume-joshuahall`)

## Remaining Resources

- [ ] CloudFront Distribution (`E2X0J4ARP0Z9E2`)
- [ ] WAF WebACL (`CreatedByCloudFront-c1506055`)
- [ ] ACM Certificate (`joshuahall.tech`)

## Cleanup Commands

Run these in order:

### 1. Delete CloudFront Distribution

```bash
ETAG=$(aws cloudfront get-distribution-config --id E2X0J4ARP0Z9E2 --query 'ETag' --output text)
aws cloudfront delete-distribution --id E2X0J4ARP0Z9E2 --if-match "$ETAG"
```

### 2. Delete WAF WebACL

```bash
LOCK=$(aws wafv2 get-web-acl --name CreatedByCloudFront-c1506055 --scope CLOUDFRONT --id e7a26c8f-a0e9-404e-88fe-6dcefdbd3fbe --region us-east-1 --query 'LockToken' --output text)
aws wafv2 delete-web-acl --name CreatedByCloudFront-c1506055 --scope CLOUDFRONT --id e7a26c8f-a0e9-404e-88fe-6dcefdbd3fbe --region us-east-1 --lock-token "$LOCK"
```

### 3. Delete ACM Certificate

```bash
aws acm delete-certificate --certificate-arn arn:aws:acm:us-east-1:748955969582:certificate/7acb27f7-927c-4c1e-8ddd-1e4c6970e4d2
```

## Verify All Resources Are Gone

```bash
aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Aliases.Items[0]]' --output table
aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 --query 'WebACLs[*].Name' --output table
aws acm list-certificates --query 'CertificateSummaryList[*].DomainName' --output table
```

All commands should return empty results.
