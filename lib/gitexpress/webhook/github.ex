defmodule GitExPress.Webhook.GitHub do
  @moduledoc """
  Plug for GitHub webhook.

  All plugs must implement at least init/1 and call/2.
  """
  import Plug.Conn
  require Logger
  alias Plug.Crypto

  @path Application.get_env(:gitexpress, :github_webhook_path)
  @secret Application.get_env(:gitexpress, :github_webhook_secret)
  @action Application.get_env(:gitexpress, :github_webhook_action)

  @doc """
  The init/1 function is used to initialize our Plug’s options.
  """
  def init(options) do
    options
  end

  @doc """
  The call/2 function is called for every new request that comes in from the web
  server. It receives a %Plug.Conn{} connection struct as its first argument and
  is expected to return a %Plug.Conn{} connection struct. Used to verify the secret.
  """
  def call(conn, options) do
    path = @path

    # Check if request path matches the configured one
    case conn.request_path do
      ^path ->
        {module, function} = @action

        # get the payload and the signature from the request.
        # ("x-hub-signature") is the GitHub-specific way to pass on the signature.
        [signature] = get_header(conn, "x-hub-signature")
        {:ok, payload, _conn} = read_body(conn)

        case verify_signature(payload, signature) do
          true ->
            apply(module, function, [conn, payload])
            handle_success(conn)

          false ->
            handle_failure(conn)
        end

      _ ->
        conn
    end
  end

  @doc """
  Compare the sha1 signature of the incoming webhook request and the one calculated
  based on our config value, and see if they match. Requests are allowed only
  when the signatures match each other.
  """
  def verify_signature(payload, signature) do
    local_signature =
      "sha1=" <>
        (:crypto.hmac(:sha, @secret, payload)
         |> Base.encode16(case: :lower))

    # Compares the two binaries in constant-time to avoid timing attacks
    Crypto.secure_compare(local_signature, signature)
  end

  defp handle_success(conn) do
    conn
    |> send_resp(200, "OK")
    |> halt()
  end

  defp handle_failure(conn) do
    conn
    |> send_resp(403, "Forbidden")
    |> halt()
  end

  # Get request header value for a given key
  defp get_header(conn, key) do
    get_req_header(conn, key)
  end
end
