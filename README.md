# Internal Wiki

It is a Wiki for use in a limited environment.


# How To Use

## clone sourcecode

```
git clone git://github.com/n-sakuma/internal_wiki.git
```

## cp sample files

### DB

```
cp config/database.yml{.sample,}

```

### groonga

```
cp config/groonga.yml{.sample,}
```

### application settings

```
cp config/application.yml{.sample}
```

#### [Option] Get Google OAuth key

Using OAuth 2.0 to Access Google APIs

[Document](https://developers.google.com/accounts/docs/OAuth2)


## migration

### DB

```
rake db:migrate
```

### groonga

```
rake groonga:migrate
```



# For Developer

## view routes on browser

```
http://localhost:3000/rails/routes
```

## Smart development log view (Chrome only)

Install the extension from [Chrome WebStore.](https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)
