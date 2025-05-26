#!/bin/sh
which tenv && tenv opentofu install
tofu apply -var-file secret.tfvars

