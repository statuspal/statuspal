defmodule StatushqWeb.Admin.StatusPageView do
  use StatushqWeb, :view

  def render("subheader.html", assigns = %{conn: %{private: %{phoenix_action: phoenix_action}}})
    when phoenix_action not in [:index, :new, :create] do
      render(StatushqWeb.Admin.SharedView, "main_actions.html", assigns)
  end
  def render("subheader.html", assigns) do
    render(StatushqWeb.Admin.SharedView, "user_subheader.html", assigns)
  end

  def render("title", _assigns = %{conn: %{private: %{phoenix_action: phoenix_action}}}) do
    case phoenix_action do
      :show -> "Dashboard"
      :billing -> "Billing"
      :edit -> "Settings"
      _ -> nil
    end
  end

  def page_styles(status_page) do
    styles = if status_page.header_bg_color1 do
      h_style = if status_page.header_bg_color2 do
        "linear-gradient(to right, ##{status_page.header_bg_color1}, ##{status_page.header_bg_color2})"
      else
        "##{status_page.header_bg_color2}"
      end
      ".header { background: #{h_style}; }\n"
    else
      ""
    end

    styles = styles <> if status_page.header_fg_color do
      ".header a { color: ##{status_page.header_fg_color} !important; }\n"
    else
      ""
    end

    styles = styles <> if status_page.incident_link_color do
      ".incidents-table a { color: ##{status_page.incident_link_color} !important; }\n"
    else
      ""
    end

    styles = styles <> if status_page.incident_header_color do
      "h1 { color: ##{status_page.incident_header_color} !important; }\n"
    else
      ""
    end

    styles
  end
end
