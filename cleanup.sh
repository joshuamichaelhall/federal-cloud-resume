#!/bin/bash

# AWS Cloud Resume Cleanup Script
# This script destroys all AWS resources created by Terraform

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

# Confirm destruction
confirm_destruction() {
    echo ""
    echo "======================================"
    log_warn "WARNING: This will destroy ALL AWS resources created by this project!"
    echo "======================================"
    echo ""
    echo "This includes:"
    echo "  - S3 Bucket and all files"
    echo "  - CloudFront Distribution"
    echo "  - Lambda Function"
    echo "  - DynamoDB Table (and all data)"
    echo "  - API Gateway"
    echo "  - IAM Roles and Policies"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Cleanup cancelled."
        exit 0
    fi
}

# Empty S3 bucket before destruction
empty_s3_bucket() {
    log_info "Emptying S3 bucket..."

    cd terraform

    if [ ! -d ".terraform" ]; then
        log_error "Terraform not initialized. Cannot get bucket name."
        cd ..
        return 1
    fi

    # Get bucket name from Terraform state
    BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")

    cd ..

    if [ -n "$BUCKET_NAME" ]; then
        log_info "Removing all objects from bucket: $BUCKET_NAME"

        # Delete all objects and versions
        aws s3 rm "s3://$BUCKET_NAME" --recursive || true

        # Delete all versions if versioning is enabled
        aws s3api delete-objects \
            --bucket "$BUCKET_NAME" \
            --delete "$(aws s3api list-object-versions \
                --bucket "$BUCKET_NAME" \
                --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
                --max-items 1000)" 2>/dev/null || true

        log_info "S3 bucket emptied"
    else
        log_warn "Could not determine S3 bucket name. Continuing with Terraform destroy..."
    fi
}

# Destroy infrastructure with Terraform
destroy_infrastructure() {
    log_info "Destroying infrastructure with Terraform..."

    cd terraform

    if [ ! -d ".terraform" ]; then
        log_error "Terraform not initialized. Nothing to destroy."
        cd ..
        exit 1
    fi

    terraform destroy -auto-approve

    cd ..

    log_info "All AWS resources have been destroyed"
}

# Main cleanup flow
main() {
    echo ""
    echo "======================================"
    echo "  AWS Cloud Resume Cleanup"
    echo "======================================"
    echo ""

    confirm_destruction
    empty_s3_bucket
    destroy_infrastructure

    echo ""
    echo "======================================"
    log_info "Cleanup complete!"
    echo "======================================"
    echo ""
    log_info "All AWS resources have been removed."
    log_info "You can safely delete this directory if you're done with the project."
    echo ""
}

# Run main function
main
