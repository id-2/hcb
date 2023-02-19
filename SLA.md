# SLA plan for HCB

## Where are we today?

Bank is slow. Airbrake has also given us a GIANT closet to sweep our messes into and say "we'll fix it later"

How are we going to fix these problems?

## 1. Airbrake Inbox Zero

Starting on Wed, Feb (22nd), we're committing to airbrake inbox zero. Every issue must be manually closed, manually ignored, or marked resolved.

#### Implementation details:

But there's too many!!1! How will we do it??2?
*The panic begins to set in....*

Don't sweat it dog. 🕶️
Let's break this boogie down to a 4-step together:

1. As of our starting day, we declare Air~~brake~~Bankruptcy
   - Over half of our issues haven't been seen in months, and may very well not be an issue anymore. dev time is more valuable than money
   - Anything that is an issue, we'll hear about when it comes up again
2. Regular triage check-in
   - we can figure out if we want this to be async or sync. hq or online. shirts or skins.
3. Tickets can be marked as "not an issue", or "one-time" issues, but we should be conciously deciding to skip them
4. Dedicated time for bugfixes in future sprint/agile/unit-of-work planning

Feel the beat? Ready to 🎵play along🎶?

## 2. Error on lag

Which brings me back to the original topic of this five-paragraph persuasive essay...

The world is full of great tools for tracking this! New Relic! Lighthouse! Others!

**And they're all giant complex tools that need to be learned.** The goal here is to speed up loadtimes, so let's skip that and hit the ground with something that we can actually start with today:

1. Middleware that automatically throws to airbrake for anything that takes over 5 seconds
  - don't actually return a 500, but make sure we record it happened
2. After no 5 second responses are happening and we're feeling cocky, drop the new limit to 4 seconds
3. %w[wash rinse repeat] ~~until we drop to 0 seconds~~