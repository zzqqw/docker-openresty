version=$(curl --silent "https://api.github.com/repos/openresty/openresty/tags" | jq -r '.[0].name')

if [[ $version =~ ^v ]]; then
  version=${version#v}
fi

echo "currentversion:$currentversion version:$version"

# 判断版本号是否相同 如果相同就exit
if [[ "$currentversion" == "$version" ]]; then
    exit
fi

echo "Submit Docker Image"
# 登录仓库
docker login -u $DOCKER_USER -p $DOCKER_PWD
# 构建仓库
docker build --build-arg="OPENRESTY_VERSION=$version" -t zhiqiangwang/openresty:$version  .
# 发布仓库
echo "Release Docker Version: " $version
docker push zhiqiangwang/openresty:$version

echo "Release Docker Version latest"
# docker pull 
docker tag zhiqiangwang/openresty:$version zhiqiangwang/openresty:latest
docker push zhiqiangwang/openresty:latest

echo "Submit the latest code"
# 更新代码
echo "$version" >currentversion
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add currentversion
git commit -a -m "Auto Update to buildid: $version"
git push origin main