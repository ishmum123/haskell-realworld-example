{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DuplicateRecordFields #-}
module Conduit.Db.Schema.Comment where

import RIO
import Rel8
import Rel8.Expr.Time
import Data.Time
import Data.UUID

import Conduit.Core.User
import Conduit.Core.Article
import Conduit.Core.Comment

data CommentEntity f = CommentEntity
    { entityCommentId        :: Column f CommentId
    , entityCommentUUID      :: Column f UUID
    , entityCommentBody      :: Column f Text
    , entityCommentArticleId :: Column f ArticleId
    , entityCommentAuthorId  :: Column f UserId
    , entityCommentCreatedAt :: Column f UTCTime
    , entityCommentUpdatedAt :: Column f UTCTime
    }
    deriving stock (Generic)
    deriving anyclass (Rel8able)

deriving stock instance f ~ Result => Show (CommentEntity f)

commentSchema :: TableSchema (CommentEntity Name)
commentSchema = TableSchema
    { name = "comments"
    , schema = Nothing
    , columns = CommentEntity
        { entityCommentId        = "id"
        , entityCommentUUID      = "uuid"
        , entityCommentBody      = "body"
        , entityCommentArticleId = "article_id"
        , entityCommentAuthorId  = "user_id"
        , entityCommentCreatedAt = "created_at"
        , entityCommentUpdatedAt = "updated_at"
        }
    }

mapCommentEntityToComment :: CommentEntity Result -> Comment
mapCommentEntityToComment entity = Comment
    { commentId        = entityCommentId entity
    , commentUUID      = entityCommentUUID entity
    , commentBody      = entityCommentBody entity
    , commentArticleId = entityCommentArticleId entity
    , commentAuthorId  = entityCommentAuthorId entity
    , commentCreatedAt = entityCommentCreatedAt entity
    , commentUpdatedAt = entityCommentUpdatedAt entity
    }

getCommentByIdStmt :: Expr CommentId -> Query (CommentEntity Expr)
getCommentByIdStmt commentId = do
    comment <- each commentSchema
    where_ $ entityCommentId comment ==. commentId
    return comment

getCommentByUUIDStmt :: Expr UUID -> Query (CommentEntity Expr)
getCommentByUUIDStmt uuid = do
    comment <- each commentSchema
    where_ $ entityCommentUUID comment ==. uuid
    return comment

getCommentsByArticleIdStmt :: Expr ArticleId -> Query (CommentEntity Expr)
getCommentsByArticleIdStmt articleId = do
    comment <- each commentSchema
    where_ $ entityCommentArticleId comment ==. articleId
    return comment

insertCommentStmt :: Comment -> Insert [CommentId]
insertCommentStmt comment = Insert
    { into = commentSchema
    , rows = values [
        CommentEntity
            { entityCommentId        = unsafeCastExpr $ nextval "comments_id_seq"
            , entityCommentUUID      = lit $ commentUUID comment
            , entityCommentBody      = lit $ commentBody comment
            , entityCommentArticleId = lit $ commentArticleId comment
            , entityCommentAuthorId  = lit $ commentAuthorId comment
            , entityCommentCreatedAt = now
            , entityCommentUpdatedAt = now
            }
        ]
    , onConflict = Abort
    , returning = Projection entityCommentId
    }

deleteCommentStmt :: CommentId -> Delete Int64
deleteCommentStmt commentId = Delete
    { from = commentSchema
    , using = pure ()
    , deleteWhere = \_ row -> entityCommentId row ==. lit commentId
    , returning = NumberOfRowsAffected
    }

deleteCommentByArticleIdStmt :: ArticleId -> Delete Int64
deleteCommentByArticleIdStmt articleId = Delete
    { from = commentSchema
    , using = pure ()
    , deleteWhere = \_ row -> entityCommentArticleId row ==. lit articleId
    , returning = NumberOfRowsAffected
    }
