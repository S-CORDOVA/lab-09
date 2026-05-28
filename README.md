# Lab 9 — VetClinic: Authorization with Pundit

## Objective

Build on the authentication you added in Lab 8 by introducing **authorization** — deciding *what* each signed-in user is allowed to do — using **Pundit**, a small but widely adopted authorization library in the Rails ecosystem.

By the end of this lab, the same VetClinic action will succeed or fail depending on the role and identity of the signed-in user: an admin can do everything, a vet can manage only their own appointments and treatments, and an owner-role user can only see and manage their own owner record, pets, and appointments.

The lab is intentionally lighter on step-by-step instructions than the procedural labs (5–7). Pundit is tiny — its README is short enough that you can read it end-to-end in one sitting — and a large part of using it well is internalizing how policies, scopes, and the controller helpers fit together. Plan on reading the README before writing code.

## Reference Material

Your primary references for this lab live in the Pundit repository on GitHub:

- **Pundit README** — <https://github.com/varvet/pundit>
- **Pundit Wiki** — <https://github.com/varvet/pundit/wiki>

The README in particular covers everything you need for this lab: installation, the structure of a policy, the `Scope` inner class, controller helpers (`authorize`, `policy_scope`), the `verify_authorized` / `verify_policy_scoped` after-actions, headless policies, permitted-attributes, view helpers, and rescuing `Pundit::NotAuthorizedError`. Treat it as required reading.

Supporting Rails documentation:

- **Active Record Associations — `belongs_to`** — <https://guides.rubyonrails.org/association_basics.html#the-belongs-to-association>
- **Action Controller Overview — Rescue** — <https://guides.rubyonrails.org/action_controller_overview.html#rescue>

## Setup

In this lab you will continue working on the VetClinic application you built in Lab 8, but you must submit it in a **new repository**. Your Lab 8 repository will not be reviewed for this lab.

1. **Create a new, empty repository** on GitHub (no README, no .gitignore, no license — completely empty). Make sure it is **public** so the teaching assistant can review it.

2. In your local `vet_clinic` project from Lab 8, add the new repository as a remote and push your code:

```bash
cd vet_clinic
git remote add lab9 <your-new-repo-url>
git push -u lab9 main
```

3. Verify on GitHub that your code is now in the new repository.

4. From now on, push your Lab 9 work to this new remote:

```bash
git push lab9 main
```

5. **Submit the link to your new repository on Canvas.**

## Requirements

The application must satisfy every requirement below. The Pundit README is enough to fulfill all of them; you should not need to copy-paste from blog posts or tutorials.

### User registration

Authorization assumes every signed-in `User` is linked to an `Owner` or a `Vet` (or is an admin). Open self-registration would create orphan users with role `:owner` but no `Owner` record, breaking every policy that scopes by `current_user`'s associated record.

- Remove `:registerable` from the `User` model so that Devise no longer exposes the sign-up flow. The route `/users/sign_up` must no longer exist; any link to it (in views, the navbar, or the landing page) must be removed.
- The only way to create users is via seeds or the Rails console. Lab 9 does not require an admin UI for user management.
- The sign-in flow from Lab 8 is unaffected and remains the entry point for every role.

### Linking User accounts to Owner and Vet records

Lab 8 stored a `role` on `User` but did not connect a `User` to the `Owner` or `Vet` record they represent in the business domain. Authorization in this lab is built around that connection, so you must introduce it.

- `Owner` gains a `user` reference. Each owner row is associated with **at most one** `User` (the human who logs in to manage that owner's pets and appointments). The reference is optional at the database level so that owners can exist without a registered account if needed, but every seeded owner used for grading must be linked to a `User` with role `:owner`.
- `Vet` gains a `user` reference, on the same terms — optional in the database, populated for every seeded vet, pointing at a `User` with role `:vet`.
- A `User` of role `:admin` is **not** linked to any `Owner` or `Vet` record.
- Updating the seeds: `bin/rails db:drop db:create db:migrate db:seed` on a fresh database must produce a consistent dataset where the seeded `:owner` user owns at least one seeded `Owner` (with pets and appointments), and the seeded `:vet` user is assigned to at least one seeded `Vet` (with appointments and treatments). Documented credentials in the README must still let the TA sign in as each role.

### Pundit installation and infrastructure

- Pundit is installed via Bundler, included in `ApplicationController`, and its generator has been run so that `ApplicationPolicy` and `ApplicationPolicy::Scope` exist as base classes.
- `ApplicationController` configures Pundit so that:
  - Every non-`index` action in every resource controller calls `authorize` exactly once. Forgetting to call it must raise.
  - Every `index` action calls `policy_scope` exactly once. Forgetting to call it must raise.
  - Public actions that are intentionally outside authorization (the application's root page) opt out cleanly, not by deleting the enforcement.
- A `Pundit::NotAuthorizedError` raised anywhere in the application is rescued at the controller level. The user is redirected to a safe page (root or the referrer) and a flash message — using the existing flash partial from Lab 5 — explains that the action was not permitted. The application must **never** show a raw exception page to a signed-in user who clicks a forbidden link.

### Policy classes

There is one policy class per resource: `OwnerPolicy`, `PetPolicy`, `VetPolicy`, `AppointmentPolicy`, `TreatmentPolicy`. Each policy:

- Inherits from `ApplicationPolicy`.
- Defines, at minimum, the predicate methods used by its controller. You may rely on `ApplicationPolicy`'s defaults where the behavior is the same.
- Defines a `Scope` inner class inheriting from `ApplicationPolicy::Scope` and overriding `resolve` whenever its controller exposes an `index` action. The scope must return only the records the current user is allowed to list. `TreatmentPolicy` does not need a `Scope` — `TreatmentsController` from Lab 6 has no `index` action.

### Authorization rules

Implement exactly the matrix below. Where a role is missing for an action, the action must be forbidden.

**Admin (`role: :admin`)**

- Full CRUD on every resource (`Owner`, `Pet`, `Vet`, `Appointment`, `Treatment`). `policy_scope` returns every record.

**Vet (`role: :vet`)**

- `Owner`, `Pet`: read-only access to every record. `index` lists all; `show` succeeds for any record. No `create`, `update`, or `destroy`.
- `Vet`: read-only access to every vet record. The signed-in vet may additionally `edit` and `update` **their own** `Vet` row (the one whose `user_id` matches `current_user.id`). No `create` or `destroy` for any vet.
- `Appointment`: may `index` (scoped to appointments assigned to them), `show` appointments where they are the assigned vet, and `create`/`update`/`destroy` only those same appointments.
- `Treatment`: may `create`/`update`/`destroy` treatments only when the treatment's appointment is assigned to them. (No `index?`/`show?` predicates — `TreatmentsController` exposes neither action.)

**Owner (`role: :owner`)**

- `Owner`: may `show`, `edit`, and `update` **their own** owner record (the one whose `user_id` matches `current_user.id`). `OwnerPolicy::Scope#resolve` returns only that single record. No `create` or `destroy`, including on their own record.
- `Pet`: may `index` (scoped to their own pets), `show`/`edit`/`update`/`destroy` their own pets, and `create` a new pet under their own owner record. They must not be able to assign a pet to a different owner — this must be enforced through permitted attributes, not only at the UI level.
- `Vet`: may `index` and `show` any vet (so they can pick a vet when booking). No `create`, `update`, or `destroy`.
- `Appointment`: may `index` (scoped to appointments whose pet's owner is them), `show` their own appointments, and `create`/`update`/`destroy` appointments for their own pets only. Reassigning an appointment to a pet that does not belong to them must be rejected through permitted attributes.
- `Treatment`: may view treatments only via the appointment's show page (gated by `AppointmentPolicy#show?`). They may not `create`, `update`, or `destroy` treatments.

### Controllers

- Each resource controller calls `authorize` in every action except `index`, and `policy_scope(<Model>)` in `index`. The instance variable that `index` exposes to the view comes from `policy_scope`, not from `Model.all`.
- Strong parameters in `Owner`, `Pet`, `Appointment`, and `Treatment` controllers use Pundit's `permitted_attributes` so that role-restricted foreign keys are silently dropped. At minimum: `pet[owner_id]` and `appointment[pet_id]` for owner-role users, `appointment[vet_id]` and `treatment[appointment_id]` for vet-role users. Admins keep the existing form selectors for these fields. Pundit's README covers the pattern in its *Strong parameters* section.

### Views and navbar

Authorization must also drive the UI: a button the user cannot use should not be shown.

- "New pet", "Edit", "Destroy" controls on resource pages render only when the policy method for the current user returns true. Use Pundit's `policy(record)` view helper from the README, not custom role checks.
- The navbar reflects the role. Admins see Owners, Pets, Vets, Appointments. Vets see the same four. Owners see a "My account" link to their own owner page, Pets, Vets, Appointments — never a link to `/owners`. Treatments are reached from an appointment's show page in every case. Do not show any user a link that will only redirect them with a flash error.
- The flash partial from Lab 5 is used to display the "not authorized" message produced by your rescue handler.

### Seeds

`bin/rails db:drop db:create db:migrate db:seed` on a fresh database must produce a dataset that demonstrates the authorization rules:

- At least one admin user.
- At least one vet user, linked to a `Vet` record that has at least one assigned `Appointment` with at least one `Treatment`.
- At least one owner-role user, linked to an `Owner` record that has at least one `Pet` with at least one `Appointment`.
- Enough additional records (a second owner with their own pets, a second vet, appointments belonging to other vets/owners) that the TA can verify your scopes by signing in and confirming they cannot see other users' data.

Passwords must be set through the normal Devise attribute writer, as in Lab 8. `db/seeds.rb` must be rewritten so that `User` rows are created first, and `Owner`/`Vet` rows then receive the linkage via `user:` on creation.

### README

The project's `README.md` documents:

- That the application now enforces authorization, and a one-paragraph description of the role matrix (what each role can do).
- The credentials (email + password) of every seeded user, grouped by role.
- Any deviation from the matrix in this lab that the TA should know about.

## Tips on Reading the Pundit Documentation

- The README is short. Read it linearly once before writing any code; it will save you more time than skimming and grepping for the right snippet later.
- Pay particular attention to:
  - the **Policies** section, including the `headless` predicate methods that don't take a record;
  - the **Scopes** section — `policy_scope` is what makes per-user `index` actions safe, and is the most common Pundit feature to forget;
  - the **Ensuring policies and scopes are used** section — the `verify_authorized` / `verify_policy_scoped` after-actions are what make Pundit reliable in a real app;
  - the **Strong parameters** section, which is how you stop an owner-role user from forging `owner_id` on a pet form.
- `bin/rails generate pundit:policy <Model>` creates a starter policy file. Read what it generates before editing it. The generated `Scope` class is a thin wrapper — its `resolve` method is where you put your filtering logic.
- The README's *Manually retrieving policies and scopes* section explains the `policy(record)` and `policy_scope(scope)` helpers available in views — these are how you hide buttons from users who can't use them.
- If you find yourself writing `if current_user.admin?` inside a controller or a view, you are almost certainly bypassing Pundit. Move the check into a policy method and call it through `authorize` or `policy(...).method?` instead.

## Deliverables

- All requirements in the *Requirements* section above are satisfied.
- `Owner` and `Vet` are linked to `User` via `user_id`, with seeds that populate the linkage for the demonstration users.
- One policy class per resource (`OwnerPolicy`, `PetPolicy`, `VetPolicy`, `AppointmentPolicy`, `TreatmentPolicy`), each with the appropriate predicates, and a `Scope` inner class for every policy whose controller exposes an `index` action.
- Every non-`index` controller action authorizes through Pundit; every `index` action uses `policy_scope`. Missing calls must raise.
- `Pundit::NotAuthorizedError` is rescued at the controller level and surfaced through the flash partial from Lab 5.
- Resource views and the navbar hide controls the current user is not authorized to use.
- Seeded admin, vet, and owner users — with their domain records linked — documented in the README.
- A clean `bin/rails db:drop db:create db:migrate db:seed` run on a fresh database.
