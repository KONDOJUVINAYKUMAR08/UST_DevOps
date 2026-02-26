# I want to build a security feature that if user enter the wrong password
#  3 times consecutively, then their account should be locked.

def lockedUsers(attempts, limit=3):
    fail_count = {}
    locked = set()

    for user, status in attempts:
        if user in locked:
            continue
        if status == "fail":
            fail_count[user] = fail_count.get(user, 0)+1
            if fail_count[user] >= limit:
                locked.add(user)

        else:
            fail_count[user]=0
    return list(locked)

attempts = [
    ("Vinay","success"),
    ("Ravi","fail"),
    ("Ravi","fail"),
    ("Ravi","success"),
    ("Ravi","fail"),
    ("Ravi","fail"),
    ("Ravi","fail"),
    ("Ramesh","fail"),
    ("Ramesh","fail"),
    ("Ramesh","fail"),
    ("Ramesh","fail"),
]

print(lockedUsers(attempts))