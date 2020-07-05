#!/bin/sh
while IFS='|' read -r name access emailid
do
   echo "$name" is the name, "$access" is permission and email of user is "$emailid"
   aws iam create-user --user-name $name
   aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/$access --user-name $name
   aws iam create-access-key --user-name $name > credentails.txt
   value=`cat credentails.txt`
   #echo "$value"
   jq -n --arg value "$value" '{
   "Subject": {
       "Data": "Dear Client Below are credenatils of your user",
       "Charset": "UTF-8"
   },
   "Body": {
       "Text": {
           "Data": "This is the message body in text format.",
           "Charset": "UTF-8"
       },
       "Html": {
           "Data": $value,
           "Charset": "UTF-8"
       }
   }
}' > message.json
   jq -n --arg emailid "$emailid" '{ "ToAddresses":  [$emailid] }' > destination.json
   aws ses send-email --from yashpatilyeola@gmail.com --destination file://destination.json --message file://message.json
done < data.txt
