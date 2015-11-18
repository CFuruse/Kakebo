crumb :root do
  link "ホーム", root_path
end

crumb :kakebos do
  link "検索", kakebos_path
  parent :root
end

crumb :new_kakebo do
  link "データ登録", new_kakebo_path
  parent :root
end

crumb :search_month_kakebo do
  link "月単位検索", search_month_kakebos_path
  parent :kakebos
end

crumb :search_year_kakebo do
  link "年単位検索", search_year_kakebos_path
  parent :kakebos
end

crumb :search_detail_kakebo do
  link "詳細検索", search_detail_kakebos_path
  parent :kakebos
end

crumb :users do
  link "ユーザ一覧", users_path
  parent :root
end

crumb :new_user do
  link "ユーザ作成", new_user_path
  parent :root
end

# user#show
crumb :show_user do |user|
  link user.name, user
  parent :users
end

# user#edit
crumb :edit_user do |user|
  link "ユーザ更新", edit_user_path(user)
  parent :show_user, user
end

# user#new
crumb :new_user do
  link "ユーザ作成", new_user_path
  parent :root
end

crumb :new_session do
  link "サインイン", new_session_path
  parent :root
end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
