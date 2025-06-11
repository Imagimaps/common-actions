# S3 Static Website with Subdomains and WebSockets

This document explains how to use the S3 Static Website GitHub Action with multiple subdomains and WebSocket support.

## Overview

The S3 Static Website action has been extended to support multiple subdomains and WebSocket connections. This allows you to create a single S3 bucket and CloudFront distribution that can serve content from multiple subdomains and handle WebSocket connections.

## How It Works

1. The action accepts a comma-separated list of subdomains via the `subdomains` input parameter
2. For each subdomain, it:
   - Adds the subdomain to the ACM certificate as a Subject Alternative Name (SAN)
   - Adds the subdomain to the CloudFront distribution's aliases
3. All subdomains point to the same S3 bucket and CloudFront distribution
4. WebSocket support is enabled by setting the `enable_websockets` parameter to "true"

## Usage

```yaml
- name: Deploy S3 Static Website
  uses: Imagimaps/common-actions/.github/actions/s3-static-site@main
  with:
    domain: example.com
    environment: development
    environment_short_name: dev
    subdomains: blog,docs,app
    enable_websockets: "true"
    websocket_path_pattern: "/ws/*"
    aws_role_arn: ${{ secrets.AWS_ROLE_ARN }}
    aws_account_id: ${{ secrets.AWS_ACCOUNT_ID }}
```

## Input Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| domain | The domain name of the project | No | imagimaps.com |
| environment | The environment which this content is to be based in | Yes | - |
| environment_short_name | The short name of the environment | Yes | - |
| sub_environment | The sub-environment to deploy the service to | No | - |
| subdomains | A comma-separated list of additional subdomains | No | "" |
| aws_role_arn | The ARN of the role which can create and manage S3 buckets | Yes | - |
| aws_account_id | The AWS account ID where the S3 Bucket and CloudFront distribution are to be created | Yes | - |
| aws_region | AWS Region where the S3 bucket is to be created | No | ap-southeast-2 |
| destroy | Whether to destroy the infrastructure. Values are 'true', 'soft' or 'false' | No | "false" |
| enable_websockets | Whether to enable WebSocket support in the CloudFront distribution | No | "false" |
| websocket_domain | The domain name for the WebSocket origin (if different from the default) | No | "" |
| websocket_path_pattern | The path pattern for WebSocket connections | No | "/ws/*" |

## Output Parameters

| Parameter | Description |
|-----------|-------------|
| bucket-name | The name of the S3 bucket created |
| domain-name | The primary domain name for the static site |
| subdomains | The list of subdomains configured for the static site |

## DNS Configuration

After deploying, you'll need to create DNS records for each subdomain pointing to the CloudFront distribution. This can be done manually or through another automation process.

## WebSocket Support

The action now supports WebSocket connections, which are useful for real-time bidirectional communication between clients and servers. WebSockets are commonly used in:

- Chat applications
- Real-time dashboards
- Collaborative editing tools
- Live notifications
- Gaming applications

When WebSocket support is enabled:

1. The CloudFront distribution is configured to properly handle WebSocket connections
2. A specific origin request policy is created that includes the necessary WebSocket headers
3. A dedicated cache behavior is added for the WebSocket path pattern (default: "/ws/*")

The WebSocket configuration ensures that the following headers are properly forwarded:
- Sec-WebSocket-Key
- Sec-WebSocket-Version
- Sec-WebSocket-Protocol
- Sec-WebSocket-Accept
- Sec-WebSocket-Extensions
- Upgrade
- Connection

These headers are required for the WebSocket protocol handshake to work correctly through CloudFront.
