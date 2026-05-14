# Lab 8 — VetClinic: Authentication with Devise

## Objective

Add user authentication to the VetClinic application using **Devise**, the standard authentication framework in the Rails ecosystem.

By the end of this lab, opening the VetClinic in a private browser window must redirect to a sign-in page, and the application must know **who** is performing each action. The `role` you introduce in this lab will be the foundation for next week's authorization work — but in Lab 8 you will only authenticate users, not yet restrict what each role can do.

This lab is intentionally lighter on step-by-step instructions than previous ones. Devise is exceptionally well documented, and a large part of using it well is learning to navigate its README and wiki. Plan on reading the relevant sections of the documentation before writing code — *not* googling individual error messages once you are stuck.

## Reference Material

Your primary references for this lab live in the Devise repository on GitHub:

- **Devise README** — <https://github.com/heartcombo/devise>
- **Devise Wiki** — <https://github.com/heartcombo/devise/wiki>

The README in particular covers everything you need for this lab: installation, generating the model, configuring views, strong parameters, controller filters and helpers, and the available test helpers. Treat it as required reading.

Supporting Rails documentation:

- **Active Record Enums** — <https://guides.rubyonrails.org/active_record_querying.html#enums>

## Setup

In this lab you will continue working on the VetClinic application you built in Lab 7, but you must submit it in a **new repository**. Your Lab 7 repository will not be reviewed for this lab.

1. **Create a new, empty repository** on GitHub (no README, no .gitignore, no license — completely empty). Make sure it is **public** so the teaching assistant can review it.

2. In your local `vet_clinic` project from Lab 7, add the new repository as a remote and push your code:

```bash
cd vet_clinic
git remote add lab8 <your-new-repo-url>
git push -u lab8 main
```

3. Verify on GitHub that your code is now in the new repository.

4. From now on, push your Lab 8 work to this new remote:

```bash
git push lab8 main
```

5. **Submit the link to your new repository on Canvas.**

## Requirements

The application must satisfy every requirement below. The README of Devise is enough to fulfill all of them; you should not need to copy-paste from blog posts or tutorials.

### Authentication

- Devise is installed and configured. The default URL options for the development environment are set so that mailer URLs are complete.
- A `User` model exists, backed by Devise. The default Devise modules (`database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`) are enabled.
- An anonymous visitor opening any VetClinic resource page (owners, pets, vets, appointments, treatments) is redirected to the sign-in page. The application's home (root) page remains public.
- After successful sign-in or sign-out, a flash message confirms the outcome through the same flash partial you wrote in Lab 5.
- After successful sign-up, the new user is signed in automatically (Devise's default behavior).

### User domain fields

The bare Devise user (email + password) is not enough for the VetClinic. The `User` model must also have:

- `first_name` (string, required).
- `last_name` (string, required).
- `role` — an integer enum with three values, in this order: `:owner`, `:vet`, `:admin`.

Constraints on these fields:

- `first_name` and `last_name` must be validated for presence.
- `first_name` and `last_name` must be assignable on **sign-up** and on **account update**, alongside the standard Devise parameters. (See the README's *Strong Parameters* section — Devise does **not** permit unknown parameters by default.)
- `role` must **not** be assignable from any user-facing form. A user must not be able to make themselves an admin by tampering with the sign-up form. Role assignment in this lab happens only through seeds or the Rails console.

You do not need to implement any authorization based on `role` yet. The field is stored, not enforced. We will use it in Lab 9 / S12 with CanCanCan.

### Views

- Devise's default views must be generated into your application and styled with Bootstrap, consistent with the forms you built in Lab 6 (`form-control`, `form-label`, `mb-3`, `btn btn-primary`, etc.). At minimum, the **sign-in**, **sign-up**, and **edit account** forms must be styled.
- Sign-up and edit-account forms include inputs for `first_name` and `last_name`. They do **not** include an input for `role`.
- Validation errors on Devise forms render through the same `shared/_error_messages` partial you wrote in Lab 6 (or one that produces the same visual result). The look of error states on the sign-up and edit forms must match the look on the rest of the application's forms.

### Navbar

The navbar partial from Lab 4 must reflect the authentication state:

- When signed out: links to sign in and sign up.
- When signed in: the current user's full name (first + last) and a sign-out control. Sign-out must use the `DELETE` HTTP verb, not `GET`. (See the README's *Controller filters and helpers* section for the route helpers and the *button_to* / Hotwire confirmation pattern from Lab 6 for the DELETE.)

### Seeds

`bin/rails db:drop db:create db:migrate db:seed` on a fresh database must create at least three users, one of each role: an admin, a vet, and an owner. Their credentials must be documented in the README so the TA can sign in.

Passwords must be set through the normal attribute writer Devise expects — never write to `encrypted_password` directly.

### README

The project's `README.md` documents:

- That authentication is required and the application is no longer fully open.
- The credentials (email + password) of every seeded user.
- Anything you customized in the Devise flow that the TA should know about (for example, if you overrode the after-sign-in redirect or added any non-default Devise module).

## Tips on Reading the Devise Documentation

- The README is organized by *what you want to do* (install, customize views, permit parameters, add controller filters). Use its table of contents — almost every requirement in this lab maps to a specific README heading.
- When the README points you at a generator command, read what the generator produces *before* using it. `bin/rails generate devise:install` and `bin/rails generate devise User` both create files and print follow-up instructions in the terminal. Read that output.
- The Devise wiki on GitHub is a deeper, community-maintained reference. It is more useful for *specific scenarios* (overriding controllers, adding fields beyond email/password, customizing redirect paths) than for first-time setup.
- If the documentation tells you to add something to `ApplicationController` (for example, the `configure_permitted_parameters` filter), put it there — not in each individual controller. Devise is designed to be configured once at the application root.

## Deliverables

- All requirements in the *Requirements* section above are satisfied.
- Working sign-up, sign-in, edit-account, sign-out, and password-reset flows, styled with Bootstrap and integrated with the existing flash partial.
- `User` model with `first_name`, `last_name`, and `role` enum, with proper validations and permitted parameters.
- All VetClinic resource controllers require authentication; the home page is public.
- Navbar showing authentication state correctly in both signed-in and signed-out modes.
- Seeded admin, vet, and owner users, documented in the README.
- A clean `bin/rails db:drop db:create db:migrate db:seed` run on a fresh database.
