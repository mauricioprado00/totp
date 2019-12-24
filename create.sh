#!/usr/bin/env bash

source .env

account_name="$1"
account_info="$2"
account_topt=""

if [ -z "$account_name" ]; then
    echo Please provide account name:

    read account_name

    echo the acccount name $account_name
fi

if [ -z "$account_info" ]; then
    echo Please provide filename of the QR code or the topt key:

    read account_info
fi

if [ -f "$account_info" ] ; then
    account_info=$(zbarimg "$account_info" 2>/dev/null)
fi

account_topt=$(echo "$account_info" | sed 's#.*secret=##g;s#[^a-z0-9].*##gi')

if [ -d ${dir}/${account_name} ]; then
    echo "Account directory already exists."
    printf "\t ${dir}/${account_name}\n"
    exit 1
fi

if [ -z "$account_topt" ]; then
    echo "Wrong topt key for account ($account_topt)"
    exit 2
fi

echo Creating new account:
echo Account Name: $account_name
echo Topt: $account_topt

mkdir ${dir}/${account_name}
echo -n "${account_topt}" > ${dir}/${account_name}/.key
./encrypt.key.sh ${account_name}