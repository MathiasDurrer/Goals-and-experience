from otree.api import (
    models, widgets, BaseConstants, BaseSubsession, BaseGroup, BasePlayer,
    Currency as c, currency_range
)
import random


class Constants(BaseConstants):
    name_in_url = 'survey'
    players_per_group = None
    num_rounds = 1


class Subsession(BaseSubsession):
    pass


class Group(BaseGroup):
    pass

# German -------------------------------------------------------------------------------------
class Player(BasePlayer):
    age = models.IntegerField(
        verbose_name='Wie alt sind Sie?',
        min=18, max=100)

    gender = models.StringField(
        choices=['Männlich', 'Weiblich', 'Keine Angaben'],
        verbose_name='Was ist Ihr Geschlecht?',
        widget=widgets.RadioSelect)

    language_german = models.StringField(
        choices = ['Muttersprache', 'Verhandlungssicher', "Fliessend", "Grundkenntnisse"],
        verbose_name='Wie gut sind Ihre Deutschkenntnisse?')

    education = models.StringField(
        choices = ['Obligatorische Schule', 'Berufliche Grundausbildung (Lehre)',"Fachmittelschule" ,"Berufsmaturität", "gymnasiale Maturität", "Fachhochschule", "universitäre Hochschule oder höher", "Anderes"],
        verbose_name='Was ist Ihre höchste abgeschlossene Ausbildung?')

    education_major =  models.StringField(
        verbose_name='''
        Falls Sie studieren oder studiert haben, was ist/war Ihr Studienfach?''',
        blank=True
    )

    risk = models.IntegerField(
        choices=[0,1,2,3,4,5,6,7,8,9,10],
        label ='Wie schätzen Sie sich persönlich ein: Sind Sie im Allgemeinen ein risikobereiter Mensch oder versuchen Sie, Risiken zu vermeiden? ( 0 = gar nicht risikobereit, 10 = sehr risikobereit)',
        widget = widgets.RadioSelectHorizontal)

    income = models.IntegerField(
         choices = [
         [0, 'Bis 1000'],
         [1, '1001 - 2000'],
         [2, '2001 - 3000'],
         [3, '3001 - 4000'],
         [4, '4001 oder mehr'],
         [99, 'Keine Angabe']
         ],
         verbose_name = 'In welcher Kategorie befindet sich Ihr monatliches Nettoeinkommen?')

    attention1 = models.IntegerField(
        widget=widgets.RadioSelect,
        label="Was war Ihr Ziel beim Punkte sammeln?",
        choices=[
            [1, "Den Schwellenwert zu erreichen oder zu überschreiten."],
            [2, "Den Schwellenwert nicht zu erreichen und nicht zu überschreiten."],
            [3, "Es gibt keine Zielvorgabe."]
        ])

    attention2 = models.IntegerField(
        widget=widgets.RadioSelect,
        label="Was war Ihr Ziel beim Punkte abgeben?",
        choices=[
            [1, "Den Schwellenwert zu erreichen oder zu unterschreiten."],
            [2, "Den Schwellenwert nicht zu unterschreiten."],
            [3, "Es gibt keine Zielvorgabe."]
        ])

    usefulness = models.IntegerField(
        choices=[
            [1, 'Ja'],
            [2, 'Nein'],
        ],
        verbose_name="Haben Ihre Daten ausreichende Qualität um für wissenschaftliche Zwecke verwendet zu werden?",
        widget=widgets.RadioSelectHorizontal)

    usefulness_text = models.StringField(
        verbose_name='''
        Falls Sie bei der obigen Frage "Nein" angeklickt haben. Bitte beschreiben Sie kurz den Grund dafür, dass Ihre Daten keine ausreichende Qualität haben.''',
        blank=True
    )

    open_text = models.LongStringField(
        verbose_name='''
            Hier haben Sie noch Platz für allfällige Anmerkungen, Kritikpunkte oder sonstiges.''',
        blank=True
    )

    strategy = models.LongStringField(
        verbose_name='''
        Können Sie beschreiben, wie Sie entschieden haben, welche Option Sie wählen?''',
    )

    task_clear = models.IntegerField(
        choices = [
        [0, 'Unklar'],
        [1, 'Teilweise unklar'],
        [2, 'Grösstenteils klar'],
        [3, 'Absolut klar']
        ],
        verbose_name = 'Wie klar war Ihnen die Aufgabe während der Studie?',
        widget=widgets.RadioSelectHorizontal)


# ENGLISH----------------------------------------------------------------
    age_e = models.IntegerField(
        verbose_name='How old are you?',
        min=18, max=100)

    gender_e = models.StringField(
        choices=['Male', 'Female', 'Prefer not to state'],
        verbose_name='What is your gender?',
        widget=widgets.RadioSelect)

    language_eng = models.StringField(
        choices = ['Mother tongue', 'Fluent', "Good knowledge", "Basic knowledge"],
        verbose_name='How good is your English knowledge?')

    risk_e = models.IntegerField(
        choices=[0,1,2,3,4,5,6,7,8,9,10],
        label ='How do you feel about yourself: Are you generally risk seeking or are you trying to avoid risks? ( 0 = not risk seeking at all, 10 = completely risk seeking)',
        widget = widgets.RadioSelectHorizontal)

    income_e = models.IntegerField(
    choices = [
    [0, 'up to 1000'],
    [1, '1001 - 2000'],
    [2, '2001 - 3000'],
    [3, '3001 - 4000'],
    [4, '4001 - or more'],
    [99, 'Do not want to answer']
    ],
    verbose_name = 'Which category does your monthly income (in £) after tax fall into? (the amount that is available to you either from work or other sources of income)')

    attention1_e = models.IntegerField(
            widget=widgets.RadioSelect,
            label="What was your goal in rounds, in which points were increased?",
            choices=[
                [1, "The goal was to meet or to exceed the threshold."],
                [2, "The goal was not to meet and not to exceed the threshold."],
                [3, "There was no goal."]
            ])

    attention2_e = models.IntegerField(
        widget=widgets.RadioSelect,
        label="What was your goal in rounds, in which points were deducted?",
        choices=[
            [1, "The goal was to fall below the threshold."],
            [2, "The goal was not to fall below the threshold."],
            [3, "There was no goal."]
        ])

    eyesight_e = models.IntegerField(
        choices=[
            [1, 'No impairment or corrected vision (e.g. glasses/contact lenses).'],
            [2, 'Yes, i do.'],
        ],
        verbose_name="Do you have a visual impairment (poor eyesight)?",
        widget=widgets.RadioSelectHorizontal)

    usefulness_e = models.IntegerField(
        choices=[
            [1, 'Yes'],
            [2, 'No'],
        ],
        verbose_name="Is the data you just generated of sufficient quality to be useful for scientific research?",
        widget=widgets.RadioSelectHorizontal)

    usefulness_text_e = models.StringField(
        verbose_name="If you clicked No to the question above, please describe shortly why we should not use your data in our analyses?",
        blank=True
    )

    strategy_e = models.LongStringField(
         verbose_name='''
            Can you describe how you made the decision which of the two options to pick?''',
     )

    task_clear_e = models.IntegerField(
        choices = [
        [0, 'Not clear'],
        [1, 'Mostly not clear'],
        [2, 'Mostly clear'],
        [3, 'Completely clear']
        ],
        verbose_name = 'Was it clear to you what your task was during this study?',
        widget=widgets.RadioSelect)

    open_text_e = models.LongStringField(
        verbose_name='''
             Is there anything you would like us to know? (Optional)''',
        blank=True
    )

