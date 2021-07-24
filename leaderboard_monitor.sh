#!/bin/bash

validator_address="B62qjhiEXP45KEk8Fch4FnYJQ7UMMfiR3hq9ZeMUZ8ia3MbfEteSYDg"
TG_TOKEN=$1
CHAT_ID=$2

r=`curl -s 'http://uptime.minaprotocol.com/getPageData.php?pageNumber=1&_=1627162675974' \
  -H 'Connection: keep-alive' \
  -H 'Accept: */*' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'Sec-GPC: 1' \
  -H 'Referer: http://uptime.minaprotocol.com/' \
  -H 'Accept-Language: en,ru;q=0.9' \
  -H 'dnt: 1' \
  --compressed \
  --insecure | grep -A 3 -B 3 $validator_address | grep 'td scope="row">' | egrep -o "[0-9]+"`
previous_place=${r}


send_message() {
  if [[ ${TG_TOKEN} != "" ]]; then
    local tg_msg="$@"
    curl -s -H 'Content-Type: application/json' --request 'POST' -d "{\"chat_id\":\"${TG_CHAT_ID}\",\"text\":\"${tg_msg}\"}" "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
  fi
}


while true; do
  sleep 300
  
  new_place=$r
  echo -e "previous_place=${previous_place} new_place=${new_place}"
  if [ $previous_place -gt  $new_place ]; then
    msg="We have lost $(echo ${previous_place}-${new_place} | bc) position(s). Current position is ${new_place}"
    previous_place=${new_place}
    send_message ${msg}
    
  elif [ $previous_place -lt  $new_place ]; then
    msg="We moved up $(echo ${new_place}-${previous_place} | bc) position(s), current position ${new_place}"
    previous_place=${new_place}
    send_message ${msg}
  fi
done
