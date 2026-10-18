set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list utils

# Open feature requests by votes
[script('bash')]
feats:
    set -euo pipefail

    if ! command -v gh >/dev/null 2>&1; then
        echo "GitHub CLI is required. Install it from https://cli.github.com/." >&2
        exit 1
    fi

    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
        exit 1
    fi

    discussions=$(
        gh api graphql \
            --paginate \
            --slurp \
            -f owner=getarcaneapp \
            -f name=arcane \
            -F endCursor=null \
            -f query='query($owner: String!, $name: String!, $endCursor: String) { repository(owner: $owner, name: $name) { discussions(first: 100, after: $endCursor, states: [OPEN]) { nodes { number title url category { slug } isAnswered upvoteCount reactionGroups { content users { totalCount } } } pageInfo { hasNextPage endCursor } } } }' \
        | jq -r 'map(.data.repository.discussions.nodes[] | select(.category.slug == "feature-requests") | . + {upvotes: (.upvoteCount + ([.reactionGroups[]? | select(.content == "THUMBS_UP") | .users.totalCount] | add // 0))}) | sort_by(.upvotes, .number) | reverse | .[] | [.upvotes, .number, (if .isAnswered then "answered" else "open" end), .title, .url] | @tsv'
    )

    if [ -z "$discussions" ]; then
        echo "No open feature request discussions found."
        exit 0
    fi

    echo "Open feature request discussions by votes (upvotes + 👍):"
    echo ""

    while IFS=$'\t' read -r votes number status title url; do
        printf "%3d votes - #%-4s [%s] %s\n" "$votes" "$number" "$status" "$title"
        printf "         %s\n\n" "$url"
    done <<< "$discussions"

# Fix commits since the latest release
[script('bash')]
fixes:
    set -euo pipefail

    # Colors for output
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    # Get the latest release tag
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [ -z "$LATEST_TAG" ]; then
        echo -e "${YELLOW}No previous release tag found. Showing all fix commits:${NC}"
        RANGE="HEAD"
    else
        echo -e "${GREEN}Latest release: ${LATEST_TAG}${NC}"
        RANGE="${LATEST_TAG}..HEAD"
    fi

    echo ""
    echo -e "${BLUE}=== Fix commits on main branch since ${LATEST_TAG:-beginning} ===${NC}"
    echo ""

    # List all fix commits
    FIX_COMMITS=$(git log "$RANGE" \
        --oneline \
        --no-merges \
        --grep="^fix:" \
        --grep="^hotfix:" \
        --regexp-ignore-case \
        --pretty=format:"%C(yellow)%h%Creset %C(green)%ai%Creset %s %C(dim)(%an)%Creset" || echo "")

    if [ -z "$FIX_COMMITS" ]; then
        echo "No fix commits found."
    else
        echo "$FIX_COMMITS"
    fi
