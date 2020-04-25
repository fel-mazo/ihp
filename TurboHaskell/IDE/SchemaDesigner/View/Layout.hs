module TurboHaskell.IDE.SchemaDesigner.View.Layout (findTableByName, renderColumnSelector, renderColumn, renderObjectSelector) where

import TurboHaskell.ViewPrelude
import TurboHaskell.IDE.SchemaDesigner.Types
import TurboHaskell.IDE.ToolServer.Types
import TurboHaskell.IDE.ToolServer.Layout

findTableByName tableName statements = find pred statements
    where
        pred CreateTable { name } | name == tableName = True
        pred _ = False

renderColumnSelector tableName columns = [hsx|
<div class="col-8 column-selector">
    <table class="table table-hover table-sm">
        <tbody>
            {forEach columns renderColumn}
        </tbody>
    </table>

    <a href={NewColumnAction tableName} class="btn btn-sm btn-primary">New</a>
</div>
|]

renderColumn :: Column -> Html
renderColumn Column { name, primaryKey, columnType, defaultValue } = [hsx|
<tr>
    <td>{name}</td>
    <td>{columnType}</td>
    <td>{renderDefault}</td>
    <td>{renderPrimaryKey}</td>
</tr>
|]
    where
        renderPrimaryKey = if primaryKey then [hsx|PRIMARY KEY|] else mempty
        renderDefault =
            case defaultValue of
                Just value -> [hsx|default: {value}|]
                Nothing -> mempty

renderObjectSelector statements activeObjectName = [hsx|
<div class="col object-selector">
    <h5>Objects</h5>
    {forEach statements renderObject}
    <a href={NewTableAction} class="btn btn-sm btn-primary">New</a>
</div>
|]
    where
        renderObject :: Statement -> Html
        renderObject CreateTable { name } = [hsx|<a href={ShowTableAction name} class={classes [("object object-table", True), ("active", Just name == activeObjectName)]}>{name}</a>|]
        renderObject CreateEnumType { name } = [hsx|<div class="object object-type">{name}</div>|]
        renderObject Comment {} = mempty
        renderObject AddConstraint {} = mempty
        renderObject CreateExtension {} = mempty
        renderObject statement = [hsx|<div>{statement}</div>|]
