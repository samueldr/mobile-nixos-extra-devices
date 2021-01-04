class Tasks::IntelXhciUsbSwitch < SingletonTask
  def initialize()
    Targets[:SwitchRoot].add_dependency(:Task, self)
    add_dependency(:Mount, "/sys")
  end

  def run()
    System.write("/sys/class/usb_role/intel_xhci_usb_sw-role-switch/role", "device")
  end
end
