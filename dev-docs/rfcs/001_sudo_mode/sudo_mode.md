# RFC 1: Sudo Mode

## What problem are we solving?

https://github.com/hackclub/hcb/issues/6346

User sessions remain active for long periods of time (30 days by default), which increases the risk of a third-party gaining access to their browser and performing potentially dangerous actions without needing to re-authenticate.

To mitigate this we want to implement a process similar to GitHub's [sudo mode][sudo mode], which requires users to re-authenticate when performing specific actions if they haven't already done so in the last 2 hours.

<img src="gh_sudo_mode.png" width="400"/>

[sudo mode]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/sudo-mode#about-sudo-mode

## How does authentication work today?

### Login flow

1. Users visit `/users/auth` where they `POST` a form containing an `email` field to `/logins`

   <img src="sign_in.png" width="400"/>
2. This creates a `Login` record whose `id` is used to tie together subsequent actions: https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/controllers/logins_controller.rb#L26-L46
3. Based on user preferences and the availability of `WebAuthn`, `LoginsController` drives the state machine in the `Login` model to determine what steps are required by the user and process authentication attempts (submitted to the `/logins/:id/complete` endpoint).

   <img src="email_code.png" width="400"/>
4. Once the `Login` is considered complete, we create an associated `UserSession` record: https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/controllers/logins_controller.rb#L149
5. When the user logs out we populate `UserSession#signed_out_at` and set `expiration_at` to now https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/helpers/sessions_helper.rb#L134-L142 

### Session storage

- `UserSession` records have a `session_token` property which is stored encrypted alongside its hash https://github.com/hackclub/hcb/blob/d293e57763729f69a1612606e22095761650eccd/db/schema.rb#L2140-L2141 using the [`blind_index` gem](https://github.com/ankane/blind_index).
- This session token is stored in an encrypted cookie https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/helpers/sessions_helper.rb#L107-L116, allowing us to retrieve the `UserSession` on subsequent requests https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/helpers/sessions_helper.rb#L107-L116.
- The session duration is determined by `User#session_duration_seconds` which defaults to 30 days https://github.com/hackclub/hcb/blob/d293e57763729f69a1612606e22095761650eccd/db/schema.rb#L2173.
  - This value is user-configurable from a pre-defined set of options https://github.com/hackclub/hcb/blob/ad940d9b29be634ff412b6f88f1a8e58bb624444/app/views/users/edit.html.erb#L222-L225
  - We don't currently validate this value (see https://github.com/hackclub/hcb/pull/10660)
  - When a session is created we compute the expiry time using this value and set it on both the cookie and `UserSession` https://github.com/hackclub/hcb/blob/8508ac95625ca08aef11b7919596ddb8f68c0665/app/helpers/sessions_helper.rb#L28.
- The session duration is fixed upon creation and isn't affected by user activity. There is interest in changing this: https://github.com/hackclub/hcb/issues/7258
- We don't currently clear out older sessions but this may be something worth looking into ([internal discussion](https://hackclub.slack.com/archives/C047Y01MHJQ/p1750259883680629)).
