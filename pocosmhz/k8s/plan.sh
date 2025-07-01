#!/bin/sh
which tenv && tenv opentofu install
tofu plan -var-file secret.tfvars

