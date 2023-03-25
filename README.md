# Rails on Replit

This is a template to get you started with Rails on Replit. It's ready to go so you can just hit run and start coding!

This template was generated using `rails new` (after you install the `rails` gem from the packager sidebar) so you can always do that if you prefer to set it up from scratch. We only made a couple changes to make to run it on Replit:

- bind the app on `0.0.0.0` instead of `localhost` (see `.replit`)
- allow `*.repl.co` hosts (see `config/environments/development.rb`)
- allow the app to be iframed on `replit.com` (see `config/application.rb`)

## Running the app

Simply hit run! You can edit the run command from the `.replit` file.

## Running commands

Start every command with `bundle exec` so that it runs in the context of the installed gems environment. The console pane will give you output from the server but you can run arbitrary commands from the shell without stopping the server.

## Database

SQLite would work in development but we don't recommend running it in production. Instead look into using the built-in [Replit database](http://docs.replit.com/misc/database). Otherwise you are welcome to connect databases from your favorite provider. 

## Securing your app

The default setup runs Rails in *development mode*, which is fine for learning
Rails and building small projects where security is not a big concern.
If you are building more ambitious projects with users and access control, 
you may want to tighten up the app's security. Here are the steps to securing your app:

1. Generate your master key
2. Run the `rails credentials:edit` command
3. Edit your run command to run Rails in production mode

We'll go through each step in more detail below. You can also
follow along with this [5 minute video](https://www.loom.com/share/e17ccdb58249402b95b458e6c6bedb5d) which walks you through.

### 1. Generate your master key

In rails, the master key is a master password that's used to encrypt all of the secret information
that is used by the application. Usually, this contained in a file `config/master.key`,
but in an repl, we don't store secrets in files because they are publicly viewable. Instead
we create a secret.

1. Open the "Secrets (environment variables)" panel (the lock icon)
2. Add a new secret with the key of RAILS_MASTER_KEY
3. Run these commands in the shell to generate a random key:
```
irb
require 'securerandom'
puts SecureRandom.hex(16)
```
4. Copy the random value from the shell to the secret value field
5. Refresh the browser to let the secret take affect in the shell

### 2. Run the `rails credentials:edit` command

This step will create the `config/credentials.enc.yml` file, which will contain the secret
values used by the Rails application and is encrypted with the master key. Even if someone
obtained `config/credentials.enc.yml`, they will not be able to read its contents without
your master key.

1. In the shell, run:

```
rails credentials:edit
```

2. This will open the `nano` editor which will allow you to edit the file in YAML format.
Here, you have the option of adding additional secret information, such as API keys for 3rd
party services. It will initially contain a single secret value called `secret_key_base`
which is used to encrypt session cookies. Hit Ctrl-X to exit nano and this file will be
encrypted and saved.

### 3. Edit your run command to run Rails in production mode

Now we need to tell Rails to run in production mode.
It will not use the credentials file otherwise. To do this:

1. If don't see the `.replit` file, select "Show hidden files"
under the triple dot menu on the "Files" panel.
2. Open `.replit` and find the run command. Change it to read:
`rails server --binding=0.0.0.0`
3. Hit the run button, again, and now you are running in production mode!

There are some differences between how production mode works from
dev mode. One difference is it won't show the normal Rails
welcome screen.

### More about security

If you were wondering why running in development is insecure, Rails generates
a secret_key_base based on the name of your app. So if someone knows the name of
your app, they can guess your secret_key_base.
If you'd like to learn more about security in Rails, read
[Securing Rails Applications](https://guides.rubyonrails.org/security.html) on rubyonrails.org.

## Help

If you need help you might be able to find an answer on our [docs](https://docs.replit.com) page. Feel free to report bugs and give us feedback [here](https://replit.com/support).