# Jekyll Example
The contents of this directory were created on my laptop:
```
JEKYLL_VERSION=3.8
docker run --rm --volume="$PWD:/srv/jekyll" -it jekyll/builder:$JEKYLL_VERSION jekyll new myblog
```

Notice the new directory myblog/ that is created
