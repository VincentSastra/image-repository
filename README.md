# image-repository

### Upload and See your image gallery from this website

## Features
* Granular authentication
* Batch upload
* Unlimited Size

## Try it out
* Website's URL: [image-repository-client-s3-bucket.s3-website.us-east-2.amazonaws.com](image-repository-client-s3-bucket.s3-website.us-east-2.amazonaws.com)
* Example credentials:
  * username: `example`
  * password: `HelloW0rld!
  * example credentials is automatically populated when you click the login page

## How it's built
* The backend is created with **zero** code. I used AWS API Gateway, S3 Bucket and Cognito to create the backend API. No Lambdas were used. These infrastructure and options is created using **Terraform**. 
* The client is created with **Svelte** and **Tailwind**

## Running things locally
* Clone the repository
* Install Node (14 or higher)
* Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) & [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Configure your AWS credentials by running `aws configure` on your terminal
  * If you're a `root user` you can get your access key by going to [IAM > Dashboard > Manage Access Keys > Create New Access Key](https://console.aws.amazon.com/iam/home#/security_credentials$access_key)
* Build the client code
  * Go to the client directory `cd client`
  * Install all the NPM dependencies `npm install`
  * Build the code `npm run build`
* Initialize Terraform by going to the root directory and running `terraform init`
* Create all the necessary AWS resources `terraform apply`
* Terraform will output a website url for the website hosted in S3
  * Looks like this: 
    > Apply complete! Resources: 44 added, 0 changed, 0 destroyed.
    >
    > Outputs:
    >
    > website_url = "image-repository-client-s3-bucket.s3-website.us-east-2.amazonaws.com"
* You can visit the website by going to the `website_url`
* When you're finished you can delete all the AWS resources by running `terraform destroy`
* Note that all the resources created by this Terraform project will be tagged with `Project = image-repository`

## Challenges
* CORS is my greatest enemy
* Interfacing with the S3 Bucket without any Lambda means needing to read the S3 specification thoroughly
