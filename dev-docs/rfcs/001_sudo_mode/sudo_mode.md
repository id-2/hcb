# RFC 1: Sudo Mode

## What problem are we solving?

https://github.com/hackclub/hcb/issues/6346

User sessions remain active for long periods of time (30 days by default), which
increases the risk of a third-party gaining access to their browser and
performing potentially dangerous actions without needing to re-authenticate.

To mitigate this we want to implement a process similar to GitHub's [sudo
mode][sudo mode], which requires users to re-authenticate when performing
specific actions if they haven't already done so in the last 2 hours.

![](gh_sudo_mode.png)

[sudo mode]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/sudo-mode#about-sudo-mode

## How does authentication work today?

- Users visit `/users/auth` where they `POST` a form containing an `email` field to `/logins`
- This creates a `Login` record whose `id` is used to tie together subsequent actions: https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/controllers/logins_controller.rb#L26-L46
- Based on user preferences and the availability of `WebAuthn`,
  `LoginsController` drives the state machine in the `Login` model to determine
  what steps are required by the user and process authentication attempts
  (submitted to the `/logins/:id/complete` endpoint).
- Once the `Login` is considered complete, we create an associated `UserSession` record: https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/controllers/logins_controller.rb#L149
- We store a session token in an encrypted cookie: https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/helpers/sessions_helper.rb#L107-L116
- This token points to a `UserSession` record 
- The session duration is configurable (via `User#session_duration_seconds`)
  - Users can set their own preferences: https://github.com/hackclub/hcb/blob/ad940d9b29be634ff412b6f88f1a8e58bb624444/app/views/users/edit.html.erb#L222-L225 
    - We don't seem to validate the maximum duration (we might want to change this)
  - The default is 2,592,000 seconds (30 days)
- Session TTL is tracked via `UserSession#expiration_at`
  - Session TTL is also set on the cookie: https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/helpers/sessions_helper.rb#L28
  - As far as I can tell this value is never reset during the lifetime of the session

