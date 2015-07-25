from __future__ import print_function
from __future__ import unicode_literals

import pwd

from .exceptions import ValidationError


def validator(func):
    """
    :param: none_if_invalid
    """
    def inline(value, none_if_invalid=False):
        try:
            return func(value)
        except ValidationError:
            if none_if_invalid:
                return None
            raise
    
    return inline


@validator
def username(uname):
    uname = uname.strip()
    try:
        pwd.getpwnam(uname)
    except KeyError:
        raise ValidationError("Username does not exist")
    
    return uname


@validator
def port(p):
    p = str(p)
    if not p.isnumeric():
        raise ValidationError("Port '{}' is not a number".format(p))
    return p
