{ fetchFromGitHub, ... }:

{

  mavenVersion = "3.3.9";
  
  src = fetchFromGitHub {
    owner = "apache";
    repo = "maven";
    rev = "maven-${mavenVersion}";
    hash = "sha256-qqk0FyPo0X43d9Co7qe193D9lIj6DbJ7Tu7WGoD5QkY=";
  };
  
}
