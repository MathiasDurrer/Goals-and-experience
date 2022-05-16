from otree.api import Currency as c, currency_range
from ._builtin import Page, WaitPage
from .models import Constants



class Consent_eng(Page):
  def vars_for_template(self):
    return {
    'participation_fee': self.participant.payoff_plus_participation_fee(),
    'real_world_currency_per_point': c(1).to_real_world_currency(self.session),
    'example_pay': c(12).to_real_world_currency(self.session),
    'num_vouchers': 20,
    "duration": Constants.duration,
    }


page_sequence = [
    Consent_eng
]
