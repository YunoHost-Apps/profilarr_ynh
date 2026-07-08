#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Profilarr v2 is a SvelteKit app compiled to a standalone binary with Deno.
# These helpers download sources + a pinned Deno toolchain, build in a /tmp
# scratch dir (as the $app user), and leave just the compiled binary + static
# assets behind. Shared between scripts/install and scripts/upgrade so the
# build recipe only lives in one place.

# Builds the app in a scratch dir under /tmp.
# Leaves the result at:
#   $profilarr_build_dir/profilarr  (compiled binary)
#   $profilarr_build_dir/static     (static assets, required alongside the binary)
# Call profilarr_cleanup_build afterwards to remove all build scratch space.
profilarr_build_app() {
    profilarr_build_dir="/tmp/${app}_build"
    profilarr_deno_dir="/tmp/${app}_deno_toolchain"
    profilarr_deno_cache_dir="/tmp/${app}_deno_cache"

    ynh_setup_source --dest_dir="$profilarr_build_dir"

    # Deno toolchain: build-time only, pinned to match upstream's own
    # Dockerfile builder image version (see manifest.toml for the pin).
    ynh_setup_source --source_id="deno" --dest_dir="$profilarr_deno_dir"
    chmod +x "$profilarr_deno_dir/deno"

    mkdir -p "$profilarr_deno_cache_dir"
    chown -R "$app:$app" "$profilarr_build_dir" "$profilarr_deno_dir" "$profilarr_deno_cache_dir"

    local build_target="x86_64-unknown-linux-gnu"
    if [ "$(dpkg --print-architecture)" = "arm64" ]; then
        build_target="aarch64-unknown-linux-gnu"
    fi

    pushd "$profilarr_build_dir"
        # Install dependencies (deno install)
        ynh_hide_warnings ynh_exec_as_app env \
            PATH="$profilarr_deno_dir:$PATH" \
            DENO_DIR="$profilarr_deno_cache_dir" \
            deno install --node-modules-dir

        # Build the frontend (vite build)
        ynh_hide_warnings ynh_exec_as_app env \
            PATH="$profilarr_deno_dir:$PATH" \
            DENO_DIR="$profilarr_deno_cache_dir" \
            APP_BASE_PATH="./dist/build" \
            deno run -A npm:vite build

        # Compile the backend (deno compile)
        ynh_hide_warnings ynh_exec_as_app env \
            PATH="$profilarr_deno_dir:$PATH" \
            DENO_DIR="$profilarr_deno_cache_dir" \
            deno compile --no-check \
            --allow-net --allow-read --allow-write --allow-env \
            --allow-ffi --allow-run --allow-sys \
            --target "$build_target" \
            --output dist/build/profilarr dist/build/mod.ts
    popd

    mv "$profilarr_build_dir/dist/build/profilarr" "$profilarr_build_dir/profilarr"
    mv "$profilarr_build_dir/dist/build/static" "$profilarr_build_dir/static"
}

# Removes all scratch space created by profilarr_build_app
profilarr_cleanup_build() {
    ynh_safe_rm "$profilarr_build_dir"
    ynh_safe_rm "$profilarr_deno_dir"
    ynh_safe_rm "$profilarr_deno_cache_dir"
}
