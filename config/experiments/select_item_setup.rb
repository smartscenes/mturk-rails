# This setup script will be run after the MtTask and associated User
# are created but before any MtHits/MtAssignments are created
# and before the task/HITs are submitted to Mechanical Turk

puts "Running setup script for SelectItem experiment"

task = MtTask.find_by_name("select_item")

# now you can do what you want with the task