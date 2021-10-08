from otree.api import Currency as c, currency_range
from ._builtin import Page, WaitPage
from .models import Constants


# class Prolificid(Page):
#   form_model = 'player'
#   form_fields = ['prolificid', 'browser']
#   def is_displayed(self):
#     return self.round_number == 1

# ENGLISCH -----------------------------------------------------------------------
class Consent_eng(Page):
  def is_displayed(self):
    return self.player.phase in ["familiarization"]
  def vars_for_template(self):
    return {
    'participation_fee': self.participant.payoff_plus_participation_fee(),
    'real_world_currency_per_point': c(1).to_real_world_currency(self.session),
    'example_pay': c(12).to_real_world_currency(self.session),
    'num_vouchers': 20,
    "duration": Constants.duration,
    }
  # def vars_for_template(self):
  #   return {
  #   'participation_fee': self.participant.payoff_plus_participation_fee(),
  #   }


class General_Instruction_eng(Page):
  def is_displayed(self):
    return self.player.phase in ["familiarization"]
  def vars_for_template(self):
    return {
    'duration': Constants.duration,
    }


class Coverstory_general_eng(Page):
  def vars_for_template(self):
    return {
      'num_samples': Constants.num_samples,
      'num_trials': Constants.num_trials,
      'sample_condition': self.participant.vars['sample_condition'],
    }
  def is_displayed(self):
    return self.player.phase in ["familiarization"]


class Coverstory_sample_inspection_eng(Page):
  form_model = 'player'
  def get_form_fields(player):
    if 'sample_condition' == 0:
      return ["c1e"]
    else:
      return ["c1e", "c4e"]
  def is_displayed(self):
    return self.player.phase in ["familiarization"]
  def vars_for_template(self):
    return {
      'num_samples': Constants.num_samples,
      'num_trials': Constants.num_trials,
      'goal_condition': self.participant.vars['goal_condition'],
      'sample_condition': self.participant.vars['sample_condition']
    }



class Coverstory_choice_eng(Page):
  form_model = 'player'
  form_fields = ["c2e", "c3e", "c5e"]
  def is_displayed(self):
    return self.player.phase in ["familiarization"]
  def vars_for_template(self):
    return {
      'num_samples': Constants.num_samples,
      'num_trials': Constants.num_trials,
      'goal_condition': self.participant.vars['goal_condition'],
      'sample_condition': self.participant.vars['sample_condition']
    }

class Coverstory_sum_eng(Page):
  def is_displayed(self):
    return self.round_number == (self.player.phase in ["familiarization"])
  def vars_for_template(self):
    return {
      'num_samples': Constants.num_samples,
      'num_trials': Constants.num_trials,
      'sample_condition': self.participant.vars['sample_condition']
    }
class Instruction_Choices_eng(Page):
  def is_displayed(self):
    return self.round_number == 2
  def vars_for_template(self):
    return {
      'num_trials': Constants.num_trials,
      'sample_condition': self.participant.vars['sample_condition'],
      'num_samples': Constants.num_samples,
    }

class Coverstory_check_eng(Page):
  def vars_for_template(self):
    return {
      'goal_condition': self.participant.vars['goal_condition'],
      'sample_condition': self.participant.vars['sample_condition'],
    }
  form_model = 'player'
  def get_form_fields(player):
    if 'sample_condition' == 0:
        return ["g1e","g2e", "g3e", "g4e", "g5e"]
    else:
        return ["l1e", "l2e", "l3e", "l4e"]
  def is_displayed(self):
    return self.player.phase in ["familiarization"]

class Incentives_eng(Page):
  form_model = 'player'
  form_fields = ["i4e"]
  def is_displayed(self):
    return self.player.phase in ["familiarization"]
  def vars_for_template(self):
    return({
    'participation_fee': self.participant.payoff_plus_participation_fee(),
    'bonus_amount': c(1).to_real_world_currency(self.session),
    'num_trials': Constants.num_trials,
    'sample_condition': self.participant.vars['sample_condition'],
    #'bonus_amount': Constants.bonus_amount,
    })


class NewBlock_eng(Page):
  def is_displayed(self):
    return (self.player.phase in ["stimuli_easy", "stimuli_medium", "stimuli_hard"])
  form_model = 'player'
  def vars_for_template(self):
    context =  self.player.vars_for_template()
    p = self.player
    context.update({
      'currentblock': p.block,
      'budget': p.budget,
      'success': p.get_last_success(),
      'successes': p.update_successes(),
      "pstart": p.state,
      })
    return context

class Sample(Page):
  def is_displayed(self):
    return (self.player.phase in ["familiarization", "stimuli_easy", "stimuli_medium", "stimuli_hard"])
  form_model = 'player'
  def get_form_fields(self):
    samplefields = ['sample{}'.format(i) for i in range(1, Constants.num_samples + 1)]
    drawfields = ['draw{}'.format(i) for i in range(1, Constants.num_samples + 1)]
    samplertfields = ['sample_rt_ms{}'.format(i) for i in range(1, Constants.num_samples + 1)]
    return samplefields + drawfields + samplertfields
  def vars_for_template(self):
    context = self.player.vars_for_template()
    context.update({
      'outcomes': self.participant.vars['sampling_outcomes'][self.round_number],
      'successes': self.player.get_last_success(),
      'goal_condition': self.participant.vars['goal_condition'],
      'sample_condition': self.participant.vars['sample_condition']})
    return context


class Choices(Page):
  def is_displayed(self):
    return (self.player.phase in ["familiarization", "stimuli_easy", "stimuli_medium", "stimuli_hard"])
  form_model = 'player'
  def get_form_fields(self):
    choicefields = ['choice{}'.format(i) for i in range(1, Constants.num_trials + 1)]
    statefields = ['state{}'.format(i) for i in range(1, Constants.num_trials + 2)]
    rtfields = ['rt_ms{}'.format(i) for i in range(1, Constants.num_trials + 1)]
    return choicefields + statefields + rtfields + ['success'] + ['successes']
  def vars_for_template(self):
    context =  self.player.vars_for_template()
    context.update({
      'outcomes': self.participant.vars['outcomes'][self.round_number],
      'successes': self.player.get_last_success(),
      'num_rounds': Constants.num_rounds
    })
    return context
  def before_next_page(self):
    self.player.draw_bonus()


class Payment(Page):
  def is_displayed(self):
    return self.round_number >= Constants.num_rounds
  def vars_for_template(self):
    return {
      'participation_fee': c(self.session.config['participation_fee']).to_real_world_currency(self.session),
      # 'bonus': c(self.player.bonus).to_real_world_currency(self.session),
      'bonus': c(self.player.draw_bonus()).to_real_world_currency(self.session)
      }

# page_sequence = [
#   #Consent,
#   ConsentVorstudie,
#   General_Instruction,
#   Coverstory,
#   Coverstory_gain1,
#   Coverstory_gain2,
#   Coverstory_loss1,
#   Coverstory_loss2,
#   Instruction_Choices,
#   Block_Instruction1,
#   NewBlock,
#   Choices,
#   Coverstory_check_gain,
#   Coverstory_check_loss,
#   Coverstory_sum,
#   #Incentives,
#
# ]

page_sequence = [
  Consent_eng,
  General_Instruction_eng,
  Coverstory_general_eng,
  Coverstory_sample_inspection_eng,
  Coverstory_choice_eng,
  Incentives_eng,
  Instruction_Choices_eng,
  NewBlock_eng,
  Sample,
  Choices,
  Coverstory_check_eng,
  Coverstory_sum_eng,
]
