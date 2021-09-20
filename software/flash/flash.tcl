begin_memory_edit -hardware_name "USB-Blaster \[1-3\]" -device_name "@1: 10M50DA(.|ES)/10M50DC (0x031050DD)"

update_content_to_memory_from_file -instance_index 0 -mem_file_path "quartus_main_flash.hex" -mem_file_type "hex"

end_memory_edit
