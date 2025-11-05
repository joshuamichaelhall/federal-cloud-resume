#!/bin/bash

# AWS Cloud Resume Deployment Script
# This script automates the deployment of the cloud resume project

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi

    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi

    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Run 'aws configure' first."
        exit 1
    fi

    log_info "All prerequisites met!"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    log_info "Deploying infrastructure with Terraform..."

    cd terraform

    # Initialize Terraform if needed
    if [ ! -d ".terraform" ]; then
        log_info "Initializing Terraform..."
        terraform init
    fi

    # Create terraform.tfvars if it doesn't exist
    if [ ! -f "terraform.tfvars" ]; then
        log_warn "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        log_info "Please review and customize terraform.tfvars if needed."
    fi

    # Apply Terraform
    log_info "Running Terraform apply..."
    terraform apply -auto-approve

    cd ..
}

# Update frontend with API URL
update_frontend() {
    log_info "Updating frontend with API Gateway URL..."

    cd terraform
    API_URL=$(terraform output -raw api_gateway_url)
    cd ..

    # Update script.js with the API URL
    sed -i.bak "s|const API_URL = '.*';|const API_URL = '$API_URL';|g" frontend/script.js
    rm -f frontend/script.js.bak

    log_info "Frontend updated with API URL: $API_URL"
}

# Upload frontend to S3
upload_frontend() {
    log_info "Uploading frontend files to S3..."

    cd terraform
    BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    cd ..

    aws s3 sync frontend/ "s3://$BUCKET_NAME/" \
        --exclude ".DS_Store" \
        --exclude "*.bak" \
        --delete

    log_info "Frontend files uploaded to S3 bucket: $BUCKET_NAME"
}

# Invalidate CloudFront cache
invalidate_cloudfront() {
    log_info "Invalidating CloudFront cache..."

    cd terraform
    DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
    cd ..

    aws cloudfront create-invalidation \
        --distribution-id "$DISTRIBUTION_ID" \
        --paths "/*" > /dev/null

    log_info "CloudFront cache invalidation created"
}

# Display deployment summary
show_summary() {
    log_info "Deployment complete!"
    echo ""
    echo "======================================"
    echo "     Deployment Summary"
    echo "======================================"
    echo ""

    cd terraform
    echo "Website URL: https://$(terraform output -raw cloudfront_domain_name)"
    echo "API Endpoint: $(terraform output -raw api_gateway_url)"
    echo "S3 Bucket: $(terraform output -raw s3_bucket_name)"
    echo "CloudFront Distribution: $(terraform output -raw cloudfront_distribution_id)"
    echo ""
    echo "======================================"
    echo ""
    log_info "Your resume website is now live!"
    log_warn "Note: CloudFront changes may take a few minutes to propagate globally."
    cd ..
}

# Main deployment flow
main() {
    echo ""
    echo "======================================"
    echo "  AWS Cloud Resume Deployment"
    echo "======================================"
    echo ""

    check_prerequisites
    deploy_infrastructure
    update_frontend
    upload_frontend
    invalidate_cloudfront
    show_summary
}

# Run main function
main
