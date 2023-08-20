---
toc: Game Systems
summary: Damage (D6 System).
---
# Damage

## Wound Levels
According to the open D6 sourcebook, there are two ways to handle damage, either through body points or through wound levels.

This plugin works with wound levels. When damage is inflicted on a char, the char has to roll Physique to resist the damage and the remaining damage is compared to a table and results in a wound level.

Wounds can be healed either naturally through resting for a specified amount of time and another Physique roll against the wound difficulty. Or they can be healed through an assisted heal, by a healer character rolling their healing skill against the assisted heal wound difficulty. 

You can spend character points and / or fate points on your roll.

Wounds can only improve by one level at a time.

A healer can only attempt to heal another char once per a specified time period, i.e. 24 hours.

On a critical failure, the wound level will worsen by one level.

## Assisted Healing
`heal <name>` - Rolls the best heal ability you have against the wound level difficulty of the patient.

### Spending a Fate Point
`heal/fate <name>` - You can spend a fate point to double the result of your heal roll.

### Spending a Character Point
`heal/cp <name>` - You can spend a char point to add a +1D modifier to your heal roll.

### Spending both
`heal/all <name>` - You can spend both char point and fate point on your heal roll. 

## Natural Healing
Depending on the wound level of a char there is a certain amount of time, the resting period, after which a job will be automatically generated which handles this particular process. The respective character can trigger a Physique roll from the job menu in the webportal with modifiers that will have to be reviewed by admin. The wound level will be adjusted by admin afterwards accordingly.
