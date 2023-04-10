local prefix = "t-tas-helper_"

data:extend(
{
  {
    type = "int-setting",
    name = "q-tasklist-size",
    setting_type = "startup",
    default_value = 450,
    minimum_value = 10,
    maximum_value = 4000,
    order = "a0",
  },
  {
    type = "int-setting",
    name = "q-gui-width",
    setting_type = "startup",
    default_value = 250,
    minimum_value = 100,
    maximum_value = 500,
    order = "a1",
  },
  {
    type = "bool-setting",
    name = prefix.."circles",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q1",
  },
  {
    type = "bool-setting",
    name = prefix.."reachable",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q2",
  },
  {
    type = "bool-setting",
    name = prefix.."craft",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q3",
  },
  {
    type = "bool-setting",
    name = prefix.."burn",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q4",
  },
  {
    type = "int-setting",
    name = prefix.."reachable-range",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = -5,
    maximum_value = 100,
    hidden = true,
    order = "q5",
  },
  {
    type = "int-setting",
    name = prefix.."skip-tick",
    setting_type = "runtime-global",
    default_value = 3,
    minimum_value = 1,
    maximum_value = 1000,
    hidden = true,
    order = "q6",
  },
  {
    type = "bool-setting",
    name = prefix.."craftable",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q7",
  },
  {
    type = "bool-setting",
    name = prefix.."output",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q8",
  },
  {
    type = "bool-setting",
    name = prefix.."speed_boost",
    setting_type = "runtime-global",
    default_value = true,
    hidden = true,
    order = "q9",
  },
  {
    type = "int-setting",
    name = prefix.."x",
    setting_type = "runtime-global",
    default_value = 0,
    --minimum_value = 0,
    --maximum_value = 10000,
    hidden = true,
    order = "p6",
  },
  {
    type = "int-setting",
    name = prefix.."y",
    setting_type = "runtime-global",
    default_value = 0,
    --minimum_value = 0,
    --maximum_value = 5000,
    hidden = true,
    order = "p7",
  },
})