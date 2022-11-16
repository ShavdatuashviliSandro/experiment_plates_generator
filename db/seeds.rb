# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.find_or_initialize_by(email: 'sandro@gmail.com')
user.assign_attributes(password: "12341234", password_confirmation: "12341234", full_name: "Sandro Shavdatuashvili", active: true, super_admin: true)
user.save