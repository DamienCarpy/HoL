# AWS accounts for Hands-on-Labs (HoL)
[![forthebadge](https://forthebadge.com/images/badges/open-source.svg)](https://forthebadge.com)    [![forthebadge](https://forthebadge.com/images/badges/powered-by-overtime.svg)](https://forthebadge.com)

This simple code is meant to generate several users with names stored in a `list(strings)`.

## Prerequisite

* A simple AWS account is required.
* No AWS Organization is required.

## What it does

* Defines & declare a policy
* Creates an IAM group
* Attaches the policy to the group
* Creates users
* Adds each user to the group
* Generates a programmatic key for each student
    * Stores the programmatic key in SSM with user as name and key ID as description
* Generates web console password for each student
    * Store web console password in SSM with user as name and key ID as description

>  [!CAUTION] by design, secret keys and web console password WILL appear in your `terraform.tfstate` file.

## What works
* Everything but policy, which still requires some work.

## Todo
* Make policy work :sweat_smile:
* Move policy definition to variable.