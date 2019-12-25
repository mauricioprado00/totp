
function ggp-encrypt-account-key
{
    local dir=$(base-account-dir)
    local account_name="$1"
    local key_file="${dir}/${account_name}/.key"
    local key_file_encrypted="${key_file}.gpg"
    local kid=$(base-gpg-key-id)
    local uid=$(base-gpg-user-id)

    [ "$account_name" == "" ] && \
        { echo "Usage: $0 service"; return 1; }
    [ ! -f "$key_file" ] && \
        { echo "$0 - Error: $key_file file not found."; return 2; }
    [ -f "$key_file_encrypted" ] && \
        { echo "$0 - Error: Encrypted file "$key_file_encrypted" exists."; return 3; }

    gpg2 -u "${kid}" \
        -r "${uid}" \
        --encrypt "$key_file" && safe-rm "$key_file"
}

function gpg-get-account-key
{
    local dir=$(base-account-dir)
    local account_name="$1"
    local key_file="${dir}/${account_name}/.key"
    local key_file_encrypted="${key_file}.gpg"

    # failsafe stuff
    [ "$account_name" == "" ] && \
        { echo "Usage: $0 service"; return 1; }
    [ ! -f "$key_file_encrypted" ] && \
        { echo "Error: Encrypted file "$key_file_encrypted" not found."; return 2; }

    gpg2 --quiet --decrypt "$key_file_encrypted"
}