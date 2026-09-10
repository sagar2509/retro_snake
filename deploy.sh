flutter build web --release --base-href "/retro_snake/"
cd build/web
git init
git checkout -b gh-pages
git add .
git commit -m "Auto-deploy"
git remote add origin git@github.com:sagar2509/retro_snake.git
git push origin gh-pages --force