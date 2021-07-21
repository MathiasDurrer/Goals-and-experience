from otree.api import Currency as c, currency_range
from ._builtin import Page, WaitPage
from .models import Constants


# class Prolificid(Page):
#   form_model = 'player'
#   form_fields = ['prolificid', 'browser']
#   def is_displayed(self):
#     return self.round_number == 1

# German -----------------------------------------------------------------------
class Consent(Page):
  def is_displayed(self):
    return self.round_number == 1
  def vars_for_template(self):
    return {
    'participation_fee': self.participant.payoff_plus_participation_fee(),
    'real_world_currency_per_point': c(1).to_real_world_currency(self.session),
    'example_pay': c(12).to_real_world_currency(self.session),
    'num_vouchers': 20,
    "duration": Constants.duration
    }
  # def vars_for_template(self):
  #   return {
  #   'participation_fee': self.participant.payoff_plus_participation_fee(),
  #   }

class ConsentVorstudie(Page):
  def is_displayed(self):
    return self.round_number == 1

  def vars_for_template(self):
    return {
      'participation_fee': self.participant.payoff_plus_participation_fee(),
      'real_world_currency_per_point': c(1).to_real_world_currency(self.session),
      'example_pay': c(12).to_real_world_currency(self.session),
      'num_vouchers': 20,
      "duration": Constants.duration
    }

class General_Instruction(Page):
  def is_displayed(self):
    return self.round_number == 1
  def vars_for_template(self):
    return {
    'duration': Constants.duration,
    }


class Coverstory(Page):
  form_model = 'player'
  form_fields = ["c1", "c2", "c3", "c4", "c5","c6", "c7"]
  def is_displayed(self):
    return self.round_number == 1

#class Coverstory_gain1(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_gain')

#class Coverstory_gain2(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_gain')

#class Coverstory_loss1(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')


#class Coverstory_loss2(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')

#class Coverstory_sum(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')

class Instruction_Choices(Page):
  def is_displayed(self):
    return self.round_number == 3
  def vars_for_template(self):
    context = self.player.vars_for_template()
    return context

#class Coverstory_check_gain(Page):
#  form_model = 'player'
#  form_fields = ["g1","g2", "g3", "g4"]
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_gain')

#class Coverstory_check_loss(Page):
#  form_model = 'player'
#  form_fields = ["l1","l4","l2", "l3"]
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')

#class Incentives(Page):
#  form_model = 'player'
#  form_fields = ["i1","i2", "i3", "i4"]
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')
#  def vars_for_template(self):
#    return {
#    'participation_fee': self.participant.payoff_plus_participation_fee(),
#    'real_world_currency_per_point': c(1).to_real_world_currency(self.session),
#    'example_pay': c(12).to_real_world_currency(self.session),
#    'num_vouchers': 20
#    }

class Block_Instruction1(Page):
  def is_displayed(self):
    return (self.round_number in [3,24,45,66])
  def vars_for_template(self):
    context = self.player.vars_for_template()
    p = self.player
    context.update({
      'currentblock': p.block,
      'budget': p.budget,
      'success': p.get_last_success(),
      'successes': p.update_successes(),
      "pstart": p.state,
    })
    return context

class NewBlock(Page):
  def is_displayed(self):
    return (self.player.phase in ['positive_gain'])
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


class Choices(Page):
  def is_displayed(self):
    return (self.player.phase in ['familiarization_gain', 'positive_gain'])
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
      'successes': self.player.get_last_success()})
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

#
# ENGLISCH -----------------------------------------------------------------------
class Consent_eng(Page):
  def is_displayed(self):
    return self.round_number == 1
  def vars_for_template(self):
    return {
    'participation_fee': self.participant.payoff_plus_participation_fee(),
    'real_world_currency_per_point': c(1).to_real_world_currency(self.session),
    'example_pay': c(12).to_real_world_currency(self.session),
    'num_vouchers': 20,
    "duration": Constants.duration
    }
  # def vars_for_template(self):
  #   return {
  #   'participation_fee': self.participant.payoff_plus_participation_fee(),
  #   }


class General_Instruction_eng(Page):
  def is_displayed(self):
    return self.round_number == 1
  def vars_for_template(self):
    return {
    'duration': Constants.duration,
    }


class Coverstory_eng(Page):
  form_model = 'player'
  form_fields = ["c1e", "c2e", "c3e", "c4e", "c5e","c6e", "c7e"]
  def is_displayed(self):
    return self.round_number == 1

#class Coverstory_gain1_eng(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_gain')

#class Coverstory_gain2_eng(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_gain')

#class Coverstory_loss1_eng(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')


#class Coverstory_loss2_eng(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')

#class Coverstory_sum_eng(Page):
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')

class Instruction_Choices_eng(Page):
  def is_displayed(self):
    return self.round_number == 3
  def vars_for_template(self):
    context = self.player.vars_for_template()
    return context

#class Coverstory_check_gain_eng(Page):
#  form_model = 'player'
#  form_fields = ["g1e","g2e", "g3e", "g4e"]
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_gain')

#class Coverstory_check_loss_eng(Page):
#  form_model = 'player'
#  form_fields = ["l1e","l4e","l2e", "l3e"]
#  def is_displayed(self):
#    return (self.player.phase == 'familiarization_loss')

class Incentives_eng(Page):
  form_model = 'player'
  form_fields = ["i4e"]
  def is_displayed(self):
    return self.round_number == 3
  def vars_for_template(self):
    context = self.player.vars_for_template()
    p = self.player
    context.update({
    'participation_fee': self.participant.payoff_plus_participation_fee(),
    "bonus_amount": c(1).to_real_world_currency(self.session),
    #'bonus_amount': Constants.bonus_amount,
  })
    return context


class Block_Instruction1_eng(Page):
  def is_displayed(self):
    return (self.round_number in [3,24,45,66])
  def vars_for_template(self):
    context = self.player.vars_for_template()
    p = self.player
    context.update({
      'currentblock': p.block,
      'budget': p.budget,
      'success': p.get_last_success(),
      'successes': p.update_successes(),
      "pstart": p.state,
    })
    return context

class NewBlock_eng(Page):
  def is_displayed(self):
    return (self.player.phase in ['positive_gain'])
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
    return (self.player.phase in ['familiarization_gain', 'positive_gain'])
  form_model = 'player'
  def get_form_fields(self):
    samplefields = ['sample{}'.format(i) for i in range(1, Constants.num_samples + 1)]
    drawfields = ['draw{}'.format(i) for i in range(1, Constants.num_samples + 1)]
    samplertfields = ['sample_rt_ms{}'.format(i) for i in range(1, Constants.num_samples + 1)]
    return samplefields + drawfields + samplertfields
  def vars_for_template(self):
    context =  self.player.vars_for_template()
    context.update({
      'outcomes': self.participant.vars['sampling_outcomes'][self.round_number],
      'successes': self.player.get_last_success()})
    return context


class Choices(Page):
  def is_displayed(self):
    return (self.player.phase in ['familiarization_gain', 'positive_gain'])
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
      'successes': self.player.get_last_success()})
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
  #Consent_eng,
  #General_Instruction_eng,
  #Coverstory_eng,
  #Coverstory_gain1_eng,
  #Coverstory_gain2_eng,
  #Coverstory_loss1_eng,
  #Coverstory_loss2_eng,
  #Incentives_eng,
  #Instruction_Choices_eng,
  #Block_Instruction1_eng,
  #NewBlock_eng,
  Sample,
  Choices,
  #Coverstory_check_gain_eng,
  #Coverstory_check_loss_eng,
  #Coverstory_sum_eng,

]
