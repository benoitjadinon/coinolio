1) Set one intelli-j run configuration to point to `http://localhost:8080`
and an other one called 'test' to 8181

run in terminal (within ./web)

    pub get

(not sure) Build once with the pubspec.yaml top option

2) Run in terminal 

    pub run build_runner serve
or

    pub run build_runner test --fail-on-severe -- -p chrome

and leave it running..

3) first build is slow, wait until it says `Serving 'web' on http://localhost:8080`, 

then it will only rebuild on saved changes

4) simply open `localhost:8080` in a browser

or

start a debugging session with the intelli-j debug icon

--

TIP : use the [CLI](https://github.com/google/angular_cli) to create new components : `ngdart generate component AnotherComponent`
