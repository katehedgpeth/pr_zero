defmodule TestHelpers.Guards do
  defguard is_authorization_header?(header, expected_token)
           when header == {"authorization", expected_token}

  defguard has_token?(
             headers,
             expected_token
           )
           when (is_list(headers) and
                   headers |> hd() |> is_authorization_header?(expected_token)) or
                  headers |> tl() |> hd() |> is_authorization_header?(expected_token)
end
