source "board.tcl"
source "$connectaldir/scripts/connectal-synth-ip.tcl"
source "$scriptsdir/../../fpgamake/tcl/ipcore.tcl"

if {$need_pcie == "x7_gen1x8"} {
    set pcieversion {3.0}
    set maxlinkwidth {X8}
    if {$boardname == {zc706}} {
	set maxlinkwidth {X4}
    }
    if {$boardname == {ac701}} {
	set maxlinkwidth {X4}
    }
    if {[version -short] == "2013.2"} {
	set pcieversion {2.1}
    }
    if {[version -short] >= "2015.1"} {
	set pcieversion {3.1}
    }
    connectal_synth_ip pcie_7x $pcieversion pcie_7x_0 [list CONFIG.mode_selection {Advanced} CONFIG.ASPM_Optionality {true} CONFIG.Disable_Tx_ASPM_L0s {true} CONFIG.Buf_Opt_BMA {true} CONFIG.Bar0_64bit {true} CONFIG.Bar0_Size {16} CONFIG.Bar0_Scale {Kilobytes} CONFIG.Bar2_64bit {true} CONFIG.Bar2_Enabled {true} CONFIG.Bar2_Scale {Megabytes} CONFIG.Bar2_Size {1} CONFIG.Base_Class_Menu {Memory_controller} CONFIG.Device_ID {c100} CONFIG.IntX_Generation {false} CONFIG.MSI_Enabled {false} CONFIG.MSIx_Enabled {true} CONFIG.MSIx_PBA_Offset {1f0} CONFIG.MSIx_Table_Offset {200} CONFIG.MSIx_Table_Size {10} CONFIG.Maximum_Link_Width $maxlinkwidth CONFIG.Subsystem_ID {a705} CONFIG.Subsystem_Vendor_ID {1be7} CONFIG.Use_Class_Code_Lookup_Assistant {false} CONFIG.Vendor_ID {1be7} ]
}

if {$need_pcie == "x7_gen2x8"} {
    set pcieversion {3.0}
    set maxlinkwidth {X8}
    set maxinterfacewidth {128_bit}
    set linkspeed {5.0_GT/s}
    if {$boardname == {zc706}} {
	set maxlinkwidth {X4}
	set maxinterfacewidth {64_bit}
    }
    if {$boardname == {ac701}} {
	set maxlinkwidth {X4}
	set maxinterfacewidth {64_bit}
    }
    if {[version -short] >= "2015.1"} {
	set pcieversion {3.1}
    }
    connectal_synth_ip pcie_7x $pcieversion pcie2_7x_0 [list CONFIG.mode_selection {Advanced} CONFIG.ASPM_Optionality {true} CONFIG.Disable_Tx_ASPM_L0s {true} CONFIG.Buf_Opt_BMA {true} CONFIG.Bar0_64bit {true} CONFIG.Bar0_Size {16} CONFIG.Bar0_Scale {Kilobytes} CONFIG.Bar2_64bit {true} CONFIG.Bar2_Enabled {true} CONFIG.Bar2_Scale {Megabytes} CONFIG.Bar2_Size {1} CONFIG.Base_Class_Menu {Memory_controller} CONFIG.Device_ID {c100} CONFIG.IntX_Generation {false} CONFIG.MSI_Enabled {false} CONFIG.MSIx_Enabled {true} CONFIG.MSIx_PBA_Offset {1f0} CONFIG.MSIx_Table_Offset {200} CONFIG.MSIx_Table_Size {10} CONFIG.Maximum_Link_Width $maxlinkwidth CONFIG.Subsystem_ID {a705} CONFIG.Subsystem_Vendor_ID {1be7} CONFIG.Use_Class_Code_Lookup_Assistant {false} CONFIG.Vendor_ID {1be7} CONFIG.Link_Speed $linkspeed CONFIG.Interface_Width $maxinterfacewidth CONFIG.en_ext_clk {false} CONFIG.PCIe_Debug_Ports {false} CONFIG.shared_logic_in_core {true}]
}

if {$need_pcie == "x7_gen3x8"} {
    set pcieversion {3.0}
    set maxlinkwidth {X8}
    connectal_synth_ip pcie3_7x $pcieversion pcie3_7x_0 [list CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} CONFIG.TL_PF_ENABLE_REG {false} CONFIG.vendor_id {1be7} CONFIG.PF0_DEVICE_ID {c300} CONFIG.PF0_SUBSYSTEM_VENDOR_ID {1be7} CONFIG.PF0_SUBSYSTEM_ID {a705} CONFIG.PF0_Use_Class_Code_Lookup_Assistant {false} CONFIG.pf0_base_class_menu {Memory_controller} CONFIG.pf0_bar0_64bit {true} CONFIG.pf0_bar0_size {16} CONFIG.pf0_bar2_enabled {true} CONFIG.pf0_bar2_64bit {true} CONFIG.pf0_bar2_scale {Megabytes} CONFIG.pf0_bar2_size {1} CONFIG.PF0_INTERRUPT_PIN {INTA} CONFIG.pf0_msi_enabled {false} CONFIG.pf0_msix_enabled {true} CONFIG.PF0_MSIX_CAP_TABLE_SIZE {010} CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00000200} CONFIG.PF0_MSIX_CAP_PBA_OFFSET {000001f0} CONFIG.PF0_PM_CAP_SUPP_D1_STATE {false} CONFIG.pf0_dsn_enabled {true} CONFIG.mode_selection {Advanced} CONFIG.en_ext_clk {true} CONFIG.en_msi_per_vec_masking {false}]
}

proc create_pcie_sv_hip_ast {mode} {
    global boardname
    set pcieversion {2.1}
    set maxlinkwidth {x8}
    set core_name {altera_pcie_sv_hip_ast}
    set core_version {14.0}
    set ip_name {altera_pcie_sv_hip_ast_wrapper}

    set vendor_id {0x1be7}
    set device_id {0xc100}
    set class_code {0xde5000}

	set params [ dict create ]
	dict set params lane_mask_hwtcl                      $maxlinkwidth
	dict set params gen123_lane_rate_mode_hwtcl          "Gen2 (5.0 Gbps)"
	dict set params port_type_hwtcl                      "Native endpoint"
	dict set params pcie_spec_version_hwtcl              $pcieversion
	dict set params ast_width_hwtcl                      "Avalon-ST 128-bit"
	dict set params rxbuffer_rxreq_hwtcl                 "Low"
	dict set params pll_refclk_freq_hwtcl                "100 MHz"
	dict set params set_pld_clk_x1_625MHz_hwtcl          0
    # use_rx_be_hwtcl is a deprecated signal
	dict set params use_rx_st_be_hwtcl                   1
	dict set params use_ast_parity                       0
	dict set params multiple_packets_per_cycle_hwtcl     0
	dict set params in_cvp_mode_hwtcl                    0
	dict set params use_tx_cons_cred_sel_hwtcl           0
	dict set params use_config_bypass_hwtcl              0
	dict set params hip_reconfig_hwtcl                   0
	dict set params hip_tag_checking_hwtcl               1
	dict set params enable_power_on_rst_pulse_hwtcl      0

	dict set params bar0_type_hwtcl                      1
	dict set params bar0_size_mask_hwtcl                 14
	dict set params bar0_io_space_hwtcl                  "Disabled"
	dict set params bar0_64bit_mem_space_hwtcl           "Enabled"
	dict set params bar0_prefetchable_hwtcl              "Disabled"

	dict set params bar1_type_hwtcl                      0
	dict set params bar1_size_mask_hwtcl                 0
	dict set params bar1_io_space_hwtcl                  "Disabled"
	dict set params bar1_prefetchable_hwtcl              "Disabled"

	dict set params bar2_type_hwtcl                      1
	dict set params bar2_size_mask_hwtcl                 20
	dict set params bar2_io_space_hwtcl                  "Disabled"
	dict set params bar2_64bit_mem_space_hwtcl           "Enabled"
	dict set params bar2_prefetchable_hwtcl              "Disabled"

	dict set params bar3_type_hwtcl                          0
	dict set params	bar3_size_mask_hwtcl                     0
	dict set params	bar3_io_space_hwtcl                      "Disabled"
	dict set params	bar3_prefetchable_hwtcl                  "Disabled"

	dict set params	bar4_size_mask_hwtcl                     0
	dict set params	bar4_io_space_hwtcl                      "Disabled"
	dict set params	bar4_64bit_mem_space_hwtcl               "Disabled"
	dict set params	bar4_prefetchable_hwtcl                  "Disabled"

	dict set params	bar5_size_mask_hwtcl                     0
	dict set params	bar5_io_space_hwtcl                      "Disabled"
	dict set params	bar5_prefetchable_hwtcl                  "Disabled"
	dict set params	expansion_base_address_register_hwtcl    0
	dict set params	io_window_addr_width_hwtcl               0
	dict set params	prefetchable_mem_window_addr_width_hwtcl 0

	dict set params	vendor_id_hwtcl                          $vendor_id
	dict set params	device_id_hwtcl                          $device_id
	dict set params	revision_id_hwtcl                        1
	dict set params	class_code_hwtcl                         $class_code
	dict set params	subsystem_vendor_id_hwtcl                $vendor_id
	dict set params	subsystem_device_id_hwtcl                $device_id
	dict set params	max_payload_size_hwtcl                   512
	dict set params	extend_tag_field_hwtcl                   "64"
	dict set params	completion_timeout_hwtcl                 "ABCD"
	dict set params	enable_completion_timeout_disable_hwtcl  1

	dict set params use_aer_hwtcl                            0
	dict set params ecrc_check_capable_hwtcl                 0
	dict set params ecrc_gen_capable_hwtcl                   0
	dict set params use_crc_forwarding_hwtcl                 0
	dict set params port_link_number_hwtcl                   1
	dict set params dll_active_report_support_hwtcl          0
	dict set params surprise_down_error_support_hwtcl        0
	dict set params slotclkcfg_hwtcl                         1
	dict set params msi_multi_message_capable_hwtcl          "1"
	dict set params msi_64bit_addressing_capable_hwtcl       "true"
	dict set params msi_masking_capable_hwtcl                "false"
	dict set params msi_support_hwtcl                        "true"
	dict set params enable_function_msix_support_hwtcl       1
	dict set params msix_table_size_hwtcl                    16
	dict set params msix_table_offset_hwtcl                  "512"
	dict set params msix_table_bir_hwtcl                     0
	dict set params msix_pba_offset_hwtcl                    "496"
	dict set params msix_pba_bir_hwtcl                       0

	set component_parameters {}
	foreach item [dict keys $params] {
		set val [dict get $params $item]
		lappend component_parameters --component-parameter=$item=$val
	}

    if { [string match "SIMULATION" $mode]} {
        connectal_altera_simu_ip $core_name $core_version $ip_name $component_parameters
    } else {
        connectal_altera_synth_ip $core_name $core_version $ip_name $component_parameters
    }
}

proc create_pcie_reconfig {mode} {
    set core_name {altera_pcie_reconfig_driver}
    set core_version {14.0}
    set ip_name {altera_pcie_reconfig_driver_wrapper}

    set params [ dict create ]
	dict set params INTENDED_DEVICE_FAMILY        "Stratix V"
	dict set params gen123_lane_rate_mode_hwtcl   "Gen2 (5.0 Gbps)"
	dict set params number_of_reconfig_interfaces 10

	set component_parameters {}
	foreach item [dict keys $params ] {
		set val [dict get $params $item]
		lappend component_parameters --component-parameter=$item=$val
	}

    if {[string match "SIMULATION" $mode]} {
        connectal_altera_simu_ip $core_name $core_version $ip_name $component_parameters
    } else {
        connectal_altera_synth_ip $core_name $core_version $ip_name $component_parameters
    }
}

proc create_pcie_hip_ast_ed {} {
    set core_name {altera_pcie_hip_ast_ed}
    set core_version {14.0}
    set ip_name {altera_pcie_hip_ast_ed}

    set params [ dict create ]

    dict set params device_family_hwtcl              "Stratix V"
    dict set params lane_mask_hwtcl                  "x8"
    dict set params gen123_lane_rate_mode_hwtcl      "Gen2 (5.0 Gbps)"
    dict set params pld_clockrate_hwtcl              250000000
    dict set params port_type_hwtcl                  "Native endpoint"
    dict set params ast_width_hwtcl                  "Avalon-ST 128-bit"
    dict set params extend_tag_field_hwtcl           32
    dict set params max_payload_size_hwtcl           256
    dict set params num_of_func_hwtcl                1
    dict set params multiple_packets_per_cycle_hwtcl 0
    dict set params port_width_be_hwtcl              16
    dict set params port_width_data_hwtcl            128
    dict set params avalon_waddr_hwltcl              12
    dict set params check_bus_master_ena_hwtcl       1
    dict set params check_rx_buffer_cpl_hwtcl        1
    dict set params use_crc_forwarding_hwtcl         0

	set component_parameters {}
	foreach item [dict keys $params ] {
		set val [dict get $params $item]
		lappend component_parameters --component-parameter=$item=$val
	}

    connectal_altera_synth_ip $core_name $core_version $ip_name $component_parameters
}

proc create_pcie_xcvr_reconfig {mode core_name core_version ip_name n_interface} {
 	set params [ dict create ]
	dict set params number_of_reconfig_interfaces $n_interface
	dict set params device_family                 "Stratix V"
	dict set params enable_offset                 1
	dict set params enable_lc                     1
	dict set params enable_dcd                    0
	dict set params enable_dcd_power_up           1
	dict set params enable_analog                 1
	dict set params enable_eyemon                 0
	dict set params enable_ber                    0
	dict set params enable_dfe                    0
	dict set params enable_adce                   1
	dict set params enable_mif                    0
	dict set params enable_pll                    0

	set component_parameters {}
	foreach item [dict keys $params] {
		set val [dict get $params $item]
		lappend component_parameters --component-parameter=$item=$val
	}
    if {[string match "SIMULATION" $mode]} {
        connectal_altera_simu_ip $core_name $core_version $ip_name $component_parameters
    } else {
        connectal_altera_synth_ip $core_name $core_version $ip_name $component_parameters
    }
}

if {$need_pcie == "s5_gen2x8"} {
    create_pcie_sv_hip_ast SYNTHESIS
    create_pcie_xcvr_reconfig SYNTHESIS alt_xcvr_reconfig 14.0 alt_xcvr_reconfig_wrapper 10
    create_pcie_reconfig SYNTHESIS
    create_pcie_hip_ast_ed
}

# Stratix IV PCIe requires use of Megawizard
if {$need_pcie == "s4_gen2x8"} {
	fpgamake_altera_qmegawiz $connectaldir/verilog/altera/siv_gen2x8 siv_gen2x8
}
