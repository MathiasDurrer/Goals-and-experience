from os import environ
import os

# if you set a property in SESSION_CONFIG_DEFAULTS, it will be inherited by all configs
# in SESSION_CONFIGS, except those that explicitly override it.
# the session config can be accessed from methods in your apps as self.session.config,
# e.g. self.session.config['participation_fee']

mturk_hit_settings = dict({
    'keywords': ['risk', 'goals', 'academic', 'experience', 'study'],
    'title': 'Goals and Experience ($5.025 for about 40 min, $2 possible bonus)',
    'description': 'Decide between options to reach a goal',
    'frame_height': 800,
    'template': 'global/mturk_template.html',
    'minutes_allotted_per_assignement': 80,
    'expiration_hours': 7 * 24,
    'qualification_requirements': [
        # Only US
        {
            'QualificationTypeId': "00000000000000000071",
            'Comparator': "EqualTo",
            'LocaleValues': [{'Country': "US"}]
        },
        # At least 200 HITs approved
        {
            'QualificationTypeId': "00000000000000000040",
            'Comparator': "GreaterThanOrEqualTo",
            'IntegerValues': [200]
        },
        # At least 95% of HITs approved
        {
            'QualificationTypeId': "000000000000000000L0",
            'Comparator': "GreaterThanOrEqualTo",
            'IntegerValues': [95]
        },
        ]
})


USE_I18N = True

MIDDLEWARE = [
  'django.middleware.security.SecurityMiddleware',
  'whitenoise.middleware.WhiteNoiseMiddleware'
]

STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

SESSION_CONFIG_DEFAULTS = {
    'real_world_currency_per_point': 0.25,
    'participation_fee': 0.00,
    'doc': '',
    'mturk_hit_settings': mturk_hit_settings
}


SESSION_CONFIGS = [
    dict(name='rsft_goals_and_experience_experiment',
        display_name="RSFT goals and experience",
        num_demo_participants=4,
        participation_fee=5.025,
        app_sequence=[
            'consent_page',
            #'mpl',
            #'rsft_goals_and_experience_experiment',
            #'survey'
            ],
        real_world_currency_per_point = 0.25,
        use_browser_bots = False,
        ),
]



# ISO-639 code
# for example: de, fr, ja, ko, zh-hans
LANGUAGE_CODE = 'en-us'

# e.g. EUR, GBP, CNY, JPY
REAL_WORLD_CURRENCY_CODE = 'USD'
USE_POINTS = True

ROOMS = [
    dict(
        name='econ101',
        display_name='Econ 101 class',
        participant_label_file='_rooms/econ101.txt',
    ),
    dict(name='live_demo', display_name='Room for live demo (no participant labels)'),
]

ADMIN_USERNAME = 'admin'
# for security, best to set admin password in an environment variable
ADMIN_PASSWORD = environ.get('OTREE_ADMIN_PASSWORD')
print("i am here")
print(environ.get('AWS_ACCESS_KEY_ID'))
print(environ.get('AWS_SECRET_ACCESS_KEY'))
AWS_ACCESS_KEY_ID = environ.get('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = environ.get('AWS_SECRET_ACCESS_KEY')

INSTALLED_APPS = ['otree']


# don't share this with anybody.
SECRET_KEY = 'd$vavnmwdqxbhtn@5ue^6dbhvez+)ue4mz+6$&!1#^n!=+g7e$'


