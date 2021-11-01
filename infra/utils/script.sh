## variaveis

ACCOUNT_ID=208471844409
ROLE_NAME=CodeBuildKubectlRole

## cria role

echo "criando role ${ROLE_NAME}"
echo ""

TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"

echo '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": "eks:Describe*", "Resource": "*" } ] }' > /tmp/iam-role-policy

aws iam create-role --role-name ${ROLE_NAME} --assume-role-policy-document "$TRUST" --output text --query 'Role.Arn' 2>/dev/null

aws iam put-role-policy --role-name ${ROLE_NAME} --policy-name eks-describe --policy-document file:///tmp/iam-role-policy 2>/dev/null

## patch configmap/aws-auth

echo "editando configmap/aws-auth com a role ${ROLE_NAME}"
echo ""

ROLE="    - rolearn: arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}\n      username: build\n      groups:\n        - system:masters"

kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml

kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"

echo "have a nice day =)"
echo ""