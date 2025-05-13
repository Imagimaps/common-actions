# Common GitHub Actions

This repository contains common GitHub Actions used across Imagimaps projects.

## Available Actions

### S3 Static Website

Creates and manages an S3 static website with CloudFront distribution.

#### Usage Example with Subdomains

```yaml
name: Deploy Static Website

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy S3 Static Website
        uses: Imagimaps/common-actions/.github/actions/s3-static-site@main
        with:
          domain: example.com
          environment: development
          environment_short_name: dev
          subdomains: blog,docs,app
          aws_role_arn: ${{ secrets.AWS_ROLE_ARN }}
          aws_account_id: ${{ secrets.AWS_ACCOUNT_ID }}
```

### Other Actions

- bootstrap-service: Bootstrap a new service with required AWS resources
- deploy-tf: Deploy Terraform modules
- psql-client: Run PostgreSQL client commands
- s3-static-site: Create and manage S3 static websites
- static-content-cdn: Create and manage static content CDN
